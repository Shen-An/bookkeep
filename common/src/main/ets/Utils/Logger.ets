export class Logger {
  public static info(TAG: string, ...args: any[]): void {
    this.logBase(TAG, console.info, args);
  }

  public static warn(TAG: string, ...args: any[]): void {
    this.logBase(TAG, console.warn, args);
  }

  public static log(TAG: string, ...args: any[]): void {
    this.logBase(TAG, console.log, args);
  }

  public static err(TAG: string, ...args: any[]): void {
    this.logBase(TAG, console.error, args);
  }

  private static logBase(TAG: string, logger: Function = console.log, args: any[] = []): void {
    logger("BILL_LOGGER", TAG, this.normalizeArgs(args));
  }

  private static normalizeArgs(args: any[]): string {
    let ret = "";
    for (let i = 0; i < args.length; i++) {
        typeof args[i] == 'string' ? ret += args[i] : ret += JSON.stringify(args[i]);
    }
    return ret;
  }
}