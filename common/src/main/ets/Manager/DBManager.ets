import relationalStore from '@ohos.data.relationalStore';
import { BillingInfo } from '../DataTypes/BillingInfo';
import { Logger } from '../Utils/Logger';
import { CommonConfiguration } from './CommonConfiguration';
import { BillingInfoUtils } from '../Utils/BillingInfoUtils';
import { BillingType } from '../DataTypes/BillingType';
import { BusinessError } from '@ohos.base';

let TAG = "DBManager";

export class DBManager {
  private storeInstance?: relationalStore.RdbStore;

  public constructor(context: Context) {
    relationalStore.getRdbStore(context, {
      name: CommonConfiguration.DB_MANAGER.DB_FILE_NAME,
      securityLevel: CommonConfiguration.DB_MANAGER.SECURITY_LEVEL
    })
      .then(store => {
        store.executeSql(CommonConfiguration.DB_MANAGER.SQL.INITIALIZE, [])
          .then(() => {
            Logger.info(TAG, "database initialized")
            this.storeInstance = store;
          })
          .catch((e:BusinessError) => {
            Logger.err(TAG, "error while initializing db", e);
          });
      })
      .catch((e:BusinessError) => {
        Logger.err(TAG, "error while creating dbManager instance:", e);
      });
  }

  public static getInstance(context?: Context): DBManager {
    if (globalThis.__dbManager__ == undefined)
      globalThis.__dbManager__ = new DBManager(context??globalThis.context);
    return globalThis.__dbManager__;
  }

  public async getAllBillingInfo(): Promise<BillingInfo[]> {
    return await new Promise<BillingInfo[]>(ret => {
      this.storeInstance!.query(new relationalStore.RdbPredicates(CommonConfiguration.DB_MANAGER.TABLES.BILLING.NAME), [])
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
    return await new Promise<number>(ret => {
      let bucket: relationalStore.ValuesBucket = {
        'TYPE': JSON.stringify(data.type),
        'AMOUNT': data.amount,
        'DIRECTION': data.direction,
        'TIMESTAMP': data.timestamp,
        'IMAGE': data.image??'',
        'REMARK': data.remark??''
      };
      this.storeInstance!.insert(CommonConfiguration.DB_MANAGER.TABLES.BILLING.NAME, bucket)
        .then(v => {
          ret(v);
        })
        .catch((e:BusinessError) => {
          Logger.err(TAG, "error while adding billing info", e, bucket);
          ret(-1);
        })
    })
  }

  public async searchBillingInfo(keyword: string): Promise<BillingInfo[]> {
    return await new Promise<BillingInfo[]>(ret => {
      this.storeInstance!.querySql(CommonConfiguration.DB_MANAGER.SQL.SEARCH_BILLINGS, [keyword, keyword])
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
    return await new Promise<BillingInfo[]>(ret => {
      this.storeInstance!.querySql(CommonConfiguration.DB_MANAGER.SQL.SEARCH_BY_DATE_RANGE, [start.getTime(), end.getTime()])
        .then(v => {
          let info = BillingInfoUtils.createBillingInfoArrayFromResultSet(v);
          v.close();
          ret(info);
        })
        .catch((e:BusinessError) => {
          Logger.err(TAG, "error while searching billing info by date range", start.getTime(), end.getTime(), e);
        })
    })
  }

  public async addBillingInfoType(type: BillingType): Promise<number> {
    return await new Promise<number>(ret => {
      let bucket: relationalStore.ValuesBucket = {
        "NAME": type.name,
        "ICON": JSON.stringify(type.icon)
      }
      this.storeInstance!.insert(CommonConfiguration.DB_MANAGER.TABLES.BILLING_TYPE.NAME, bucket, (e, v) => {
        if (e) {
          Logger.err(TAG, "error while adding billing type", type, e);
        }
          !e && v ? ret(v) : ret(-1);
      })
    })
  }

  public async getAllBillingInfoType(): Promise<BillingType[]> {
    return await new Promise<BillingType[]>(ret => {
      this.storeInstance!.querySql(CommonConfiguration.DB_MANAGER.SQL.GET_ALL_TYPES, [])
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
    })
  }
}