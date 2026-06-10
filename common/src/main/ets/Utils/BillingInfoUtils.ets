import relationalStore from '@ohos.data.relationalStore';
import { BillingDirection, BillingInfo } from '../DataTypes/BillingInfo';
import { Logger } from '../Utils/Logger';
import { DateUtils } from './DateUtils';
import { StringUtils } from './StringUtils';

let TAG = "DataTypes";

export class BillingInfoUtils {
  public static createEmptyBillingInfo(): BillingInfo {
    let ret: BillingInfo = {
      id: -1,
      type: { icon: $r('app.string.page_show'), name: '' },
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
        type: JSON.parse(set.getString(1)),
        amount: set.getDouble(2),
        direction: set.getLong(3),
        timestamp: set.getLong(4),
        remark: set.getString(5),
        image: set.getString(6)
      };
      return ret;
    } catch (e) {
      Logger.err(TAG, "Failed to parse ResultSet at result line", set.rowIndex, e, set);
      return BillingInfoUtils.createEmptyBillingInfo();
    }
  }

  public static createBillingInfoArrayFromResultSet(set: relationalStore.ResultSet): BillingInfo[] {
    let ret: BillingInfo[] = [];
    Logger.info(TAG, "read set ", set.columnNames);
    set.goToFirstRow();
    try {
      for (let _ = 0;_ < set.rowCount; _++) {
        ret.push(BillingInfoUtils.createBillingInfoFromResultSet(set));
        set.goToNextRow();
      }
      return ret;
    } catch (e) {
      Logger.err(TAG, "Failed to parse ResultSet at result line", set.rowIndex, e, set);
      return ret;
    }
  }

  public static filterByDate(src: BillingInfo[], start: Date, end?: Date): BillingInfo[] {
    let startStamp = start.getTime();
    let endStamp = end ? end.getTime() : startStamp * 2;
    return src.filter((i) => (i.timestamp >= startStamp && i.timestamp < endStamp));
  }

  public static filterByTypeName(src: BillingInfo[], keyword: string): BillingInfo[] {
    return src.filter((i) => i.type.name.includes(keyword));
  }

  public static explodeMonthlyArray(src: BillingInfo[], month: Date): BillingInfo[][] {
    let totalDay = DateUtils.getDayNumByJSMonth(month);
    const cursor = new Date(month.getTime());
    cursor.setHours(0, 0, 0, 0);
    Logger.info(TAG, "exploding src length: ", src.length)
    let ret: BillingInfo[][] = [];
    for (let i = 1;i <= totalDay; i++) {
      cursor.setDate(i);
      let nextDay = new Date(cursor.getTime() + 1000 * 60 * 60 * 24);
      let temp = BillingInfoUtils.filterByDate(src, cursor, nextDay);
      Logger.info(TAG, "explode info - time: ", StringUtils.formatDate(cursor, 'Y-M-D h:m:s'), "next day: ", StringUtils.formatDate(nextDay, 'Y-M-D h:m:s'), "length: ", temp.length);
      ret.push(temp);
    }
    return ret;
  }

  public static explodeYearlyArray(src: BillingInfo[], year: Date): BillingInfo[][] {
    const cursor = new Date(year.getTime());
    cursor.setFullYear(cursor.getFullYear(), 1, 1);
    cursor.setHours(0, 0, 0, 0);
    Logger.info(TAG, "exploding src length: ", src.length)
    let ret: BillingInfo[][] = [];
    for (let i = 0;i < 12; i++) {
      cursor.setMonth(i);
      let nextMonth = new Date(cursor.getTime() + 1000 * 60 * 60 * 24 * DateUtils.getDayNumByJSMonth(cursor));
      let temp = BillingInfoUtils.filterByDate(src, cursor, nextMonth);
      Logger.info(TAG, "explode info - time: ", StringUtils.formatDate(cursor, 'Y-M-D h:m:s'), "next day: ", StringUtils.formatDate(nextMonth, 'Y-M-D h:m:s'), "length: ", temp.length);
      ret.push(temp);
    }
    return ret;
  }

  public static calculateTotalIncome(src: BillingInfo[]): number {
    let ret = 0;
    for (let i = 0;i < src.length; i++) {
      if (src[i].direction == BillingDirection.IN) ret += src[i].amount;
    }
    return ret;
  }

  public static calculateTotalOutBill(src: BillingInfo[]): number {
    let ret = 0;
    for (let i = 0;i < src.length; i++) {
      if (src[i].direction == BillingDirection.OUT) ret += src[i].amount;
    }
    return ret;
  }

  public static calculateTotalLeft(src: BillingInfo[]): number {
    let ret = 0;
    for (let i = 0;i < src.length; i++) {
        src[i].direction == BillingDirection.IN ? ret += src[i].amount : ret -= src[i].amount;
    }
    return ret;
  }

  public static setToArray(set: Set<string>): string[] {
    let result: string[] = [];
    set.forEach((value: string) => {
      result.push(value);
    });
    return result;
  }
}