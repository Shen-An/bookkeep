import relationalStore from '@ohos.data.relationalStore';
import { BillingInfo } from '../DataTypes/BillingInfo';
import { Logger } from '../Utils/Logger';
import { CommonConfiguration } from './CommonConfiguration';
import { BillingInfoUtils } from '../Utils/BillingInfoUtils';
import { BillingType } from '../DataTypes/BillingType';
import { BusinessError } from '@ohos.base';

let TAG = "DBManager";

interface LatestBillingRowLog {
  id: number;
  type: string;
  amount: number;
  direction: number;
  timestamp: number;
  remark: string;
}

export class DBManager {
  private storeInstance?: relationalStore.RdbStore;
  private initPromise: Promise<void>;

  public constructor(context: Context) {
    this.initPromise = relationalStore.getRdbStore(context, {
      name: CommonConfiguration.DB_MANAGER.DB_FILE_NAME,
      securityLevel: CommonConfiguration.DB_MANAGER.SECURITY_LEVEL
    })
      .then(async store => {
        // Some ArkTS/RDB implementations don't support executing multiple statements in one executeSql.
        const initSql = CommonConfiguration.DB_MANAGER.SQL.INITIALIZE;
        const statements = initSql.split(';').map(s => s.trim()).filter(s => s.length > 0);
        for (let i = 0; i < statements.length; i++) {
          await store.executeSql(statements[i], []);
        }
        Logger.info(TAG, "database initialized");
        this.storeInstance = store;
      })
      .catch((e: BusinessError) => {
        Logger.err(TAG, "error while creating/initializing db", e);
        const message = e?.message ? e.message : String(e);
        return Promise.reject(new Error(message));
      });
  }

  private async waitForStore(): Promise<relationalStore.RdbStore | undefined> {
    if (this.storeInstance) {
      return this.storeInstance;
    }
    try {
      await this.initPromise;
    } catch (e) {
      // error already logged in initPromise
      return undefined;
    }
    return this.storeInstance;
  }

  public static getInstance(context?: Context): DBManager {
    if (globalThis.__dbManager__ == undefined)
      globalThis.__dbManager__ = new DBManager(context??globalThis.context);
    return globalThis.__dbManager__;
  }

  public async getAllBillingInfo(): Promise<BillingInfo[]> {
    const store = await this.waitForStore();
    if (!store) {
      Logger.err(TAG, "db not ready while query all billing info");
      return [];
    }
    return await new Promise<BillingInfo[]>(ret => {
      store.query(new relationalStore.RdbPredicates(CommonConfiguration.DB_MANAGER.TABLES.BILLING.NAME), [])
        .then(v => {
          let info = BillingInfoUtils.createBillingInfoArrayFromResultSet(v);
          v.close();
          ret(info);
        })
        .catch((e:BusinessError) => {
          Logger.err(TAG, "error while query all billing info:", e);
          ret([]);
        })
    })
  }

  public async addBillingInfo(data: BillingInfo): Promise<number> {
    const store = await this.waitForStore();
    if (!store) {
      Logger.err(TAG, "db not ready while adding billing info");
      return -2;
    }
    return await new Promise<number>(ret => {
      let bucket: relationalStore.ValuesBucket = {
        'TYPE': JSON.stringify(data.type),
        'AMOUNT': data.amount,
        'DIRECTION': data.direction,
        'TIMESTAMP': data.timestamp,
        'IMAGE': data.image??'',
        'REMARK': data.remark??''
      };
      store.insert(CommonConfiguration.DB_MANAGER.TABLES.BILLING.NAME, bucket)
        .then(async (v: number) => {
          Logger.info(TAG, "addBillingInfo insert result", v);
          // Fire-and-forget debug logs to help verify persistence.
          this.getBillingCount()
            .then((count: number) => Logger.info(TAG, "billing count", count))
            .catch((_e: Error) => {
              return;
            });
          this.logLatestBillings(3);

          ret(v);
        })
        .catch((e:BusinessError) => {
          Logger.err(TAG, "error while adding billing info", e, bucket);
          ret(-1);
        })
    })
  }

  public async getBillingCount(): Promise<number> {
    const store = await this.waitForStore();
    if (!store) {
      return -1;
    }
    try {
      const set = await store.querySql('SELECT COUNT(*) FROM BILLING', []);
      set.goToFirstRow();
      const count = set.getLong(0);
      set.close();
      return count;
    } catch (e) {
      Logger.err(TAG, 'error while counting billings', e as BusinessError);
      return -1;
    }
  }

  public async logLatestBillings(limit: number = 3): Promise<void> {
    const store = await this.waitForStore();
    if (!store) {
      Logger.err(TAG, 'db not ready while logging latest billings');
      return;
    }
    try {
      const safeLimit = Math.max(1, Math.min(20, limit));
      // Note: LIMIT ? is supported by SQLite; if not supported by the runtime, this will be caught and logged.
      const set = await store.querySql(
        'SELECT ID, TYPE, AMOUNT, DIRECTION, TIMESTAMP, REMARK FROM BILLING ORDER BY ID DESC LIMIT ?',
        [safeLimit]
      );
      Logger.info(TAG, 'latest billings rowCount', set.rowCount);
      set.goToFirstRow();
      for (let i = 0; i < set.rowCount; i++) {
        const row: LatestBillingRowLog = {
          id: set.getLong(0),
          type: set.getString(1),
          amount: set.getDouble(2),
          direction: set.getLong(3),
          timestamp: set.getLong(4),
          remark: set.getString(5)
        };
        Logger.info(TAG, 'latest billing row', row);
        set.goToNextRow();
      }
      set.close();
    } catch (e) {
      Logger.err(TAG, 'error while logging latest billings', e as BusinessError);
    }
  }

  public async searchBillingInfo(keyword: string): Promise<BillingInfo[]> {
    const store = await this.waitForStore();
    if (!store) {
      Logger.err(TAG, "db not ready while searching billing info");
      return [];
    }
    return await new Promise<BillingInfo[]>(ret => {
      store.querySql(CommonConfiguration.DB_MANAGER.SQL.SEARCH_BILLINGS, [keyword, keyword])
        .then(v => {
          let info = BillingInfoUtils.createBillingInfoArrayFromResultSet(v);
          v.close();
          ret(info);
        })
        .catch((e:BusinessError) => {
          Logger.err(TAG, "error while searching billing info with keyword", keyword, e);
          ret([]);
        })
    })
  }

  public async searchBillingInfoByDateRange(start: Date, end: Date): Promise<BillingInfo[]> {
    const store = await this.waitForStore();
    if (!store) {
      Logger.err(TAG, "db not ready while searching billing info by date range");
      return [];
    }
    return await new Promise<BillingInfo[]>(ret => {
      store.querySql(CommonConfiguration.DB_MANAGER.SQL.SEARCH_BY_DATE_RANGE, [start.getTime(), end.getTime()])
        .then(v => {
          let info = BillingInfoUtils.createBillingInfoArrayFromResultSet(v);
          v.close();
          ret(info);
        })
        .catch((e:BusinessError) => {
          Logger.err(TAG, "error while searching billing info by date range", start.getTime(), end.getTime(), e);
          ret([]);
        })
    })
  }

  public async getBillingInfoById(id: number): Promise<BillingInfo | undefined> {
    const store = await this.waitForStore();
    if (!store) {
      Logger.err(TAG, 'db not ready while query billing by id');
      return undefined;
    }
    try {
      const set = await store.querySql('SELECT * FROM BILLING WHERE ID = ?', [id]);
      if (set.rowCount <= 0) {
        set.close();
        return undefined;
      }
      set.goToFirstRow();
      const info = BillingInfoUtils.createBillingInfoFromResultSet(set);
      set.close();
      return info;
    } catch (e) {
      Logger.err(TAG, 'error while query billing by id', id, e as BusinessError);
      return undefined;
    }
  }

  /**
   * @returns affected rows; -2: db not ready; -1: failed; >=0: deleted successfully
   */
  public async deleteBillingInfo(id: number): Promise<number> {
    const store = await this.waitForStore();
    if (!store) {
      Logger.err(TAG, 'db not ready while deleting billing info');
      return -2;
    }
    try {
      const predicates = new relationalStore.RdbPredicates(CommonConfiguration.DB_MANAGER.TABLES.BILLING.NAME)
        .equalTo('ID', id);
      const affected = await store.delete(predicates);
      Logger.info(TAG, 'deleteBillingInfo affected rows', affected);
      return affected;
    } catch (e) {
      Logger.err(TAG, 'error while deleting billing info', id, e as BusinessError);
      return -1;
    }
  }

  /**
   * Deletes all billing records.
   * @returns affected rows; -2: db not ready; -1: failed
   */
  public async deleteAllBillingInfo(): Promise<number> {
    const store = await this.waitForStore();
    if (!store) {
      Logger.err(TAG, 'db not ready while deleting all billing info');
      return -2;
    }
    try {
      const predicates = new relationalStore.RdbPredicates(CommonConfiguration.DB_MANAGER.TABLES.BILLING.NAME);
      const affected = await store.delete(predicates);
      Logger.info(TAG, 'deleteAllBillingInfo affected rows', affected);
      return affected;
    } catch (e) {
      Logger.err(TAG, 'error while deleting all billing info', e as BusinessError);
      return -1;
    }
  }

  /**
   * @returns affected rows; -2: db not ready; -1: failed
   */
  public async updateBillingInfo(data: BillingInfo): Promise<number> {
    const store = await this.waitForStore();
    if (!store) {
      Logger.err(TAG, 'db not ready while updating billing info');
      return -2;
    }
    if (typeof data.id !== 'number' || data.id < 0) {
      Logger.err(TAG, 'updateBillingInfo missing id', data);
      return -1;
    }

    const bucket: relationalStore.ValuesBucket = {
      'TYPE': JSON.stringify(data.type),
      'AMOUNT': data.amount,
      'DIRECTION': data.direction,
      'TIMESTAMP': data.timestamp,
      'IMAGE': data.image ?? '',
      'REMARK': data.remark ?? ''
    };

    try {
      const predicates = new relationalStore.RdbPredicates(CommonConfiguration.DB_MANAGER.TABLES.BILLING.NAME)
        .equalTo('ID', data.id);
      const affected = await store.update(bucket, predicates);
      return affected;
    } catch (e) {
      Logger.err(TAG, 'error while updating billing info', data.id, e as BusinessError);
      return -1;
    }
  }

  public async addBillingInfoType(type: BillingType): Promise<number> {
    const store = await this.waitForStore();
    if (!store) {
      Logger.err(TAG, "db not ready while adding billing type");
      return -2;
    }
    return await new Promise<number>(ret => {
      let bucket: relationalStore.ValuesBucket = {
        "NAME": type.name,
        "ICON": JSON.stringify(type.icon)
      }
      store.insert(CommonConfiguration.DB_MANAGER.TABLES.BILLING_TYPE.NAME, bucket, (e, v) => {
        if (e) {
          Logger.err(TAG, "error while adding billing type", type, e);
        }
          !e && v ? ret(v) : ret(-1);
      })
    })
  }

  public async getAllBillingInfoType(): Promise<BillingType[]> {
    const store = await this.waitForStore();
    if (!store) {
      Logger.err(TAG, "db not ready while querying billing types");
      return [];
    }
    return await new Promise<BillingType[]>(ret => {
      store.querySql(CommonConfiguration.DB_MANAGER.SQL.GET_ALL_TYPES, [])
        .then(set => {
          let types: BillingType[] = [];
          set.goToFirstRow();
          for (let _ = 0;_ < set.rowCount; _++) {
            types.push({
              icon: JSON.parse(set.getString(1)),
              name: set.getString(2)
            });
            set.goToNextRow();
          }
          ret(types);
        })
        .catch((e: BusinessError) => {
          Logger.err(TAG, "error while querying billing types", e);
          ret([]);
        })
    })
  }
}