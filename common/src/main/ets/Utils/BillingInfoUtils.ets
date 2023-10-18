import relationalStore from '@ohos.data.relationalStore';
import { BillingDirection, BillingInfo } from '../DataTypes/BillingInfo';
import { Logger } from '../Utils/Logger';

let TAG = "DataTypes";

export class BillingInfoUtils {
  public static createEmptyBillingInfo(): BillingInfo {
    let ret: BillingInfo = {
      id: -1,
      type: '',
      amount: 0,
      timestamp: 0,
      direction: BillingDirection.IN
    };
    return ret;
  }

  public static createBillingInfoFromResultSet(set: relationalStore.ResultSet): BillingInfo {
    try {
      let ret: BillingInfo = {
        id: set.getLong(0),
        type: set.getString(1),
        amount: set.getDouble(2),
        direction: set.getLong(3),
        timestamp: set.getLong(4),
        remark: set.getString(5),
        image: set.getString(6)
      };
      return ret;
    } catch (e) {
      Logger.err(TAG, "Failed to parse ResultSet at result line", set.rowIndex, e, set);
      return this.createEmptyBillingInfo();
    }
  }

  public static createBillingInfoArrayFromResultSet(set: relationalStore.ResultSet): BillingInfo[] {
    let ret: BillingInfo[] = [];
    Logger.info(TAG, "read set ", set.columnNames);
    set.goToFirstRow();
    try {
      for (let _ = 0;_ < set.rowCount; _++) {
        ret.push(this.createBillingInfoFromResultSet(set));
        set.goToNextRow();
      }
      return ret;
    } catch (e) {
      Logger.err(TAG, "Failed to parse ResultSet at result line", set.rowIndex, e, set);
      return ret;
    }
  }
}