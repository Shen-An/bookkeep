export class DateUtils {
  public static getDayNumByJSMonth(date: Date): number {
    let m = date.getMonth() + 1;
    let y = date.getFullYear()
    if (m == 2)
      return y % 4 ? 28 : 29;
    if (m < 8)
      return m % 2 ? 31 : 30;
    return m % 2 ? 30 : 31;
  }
}