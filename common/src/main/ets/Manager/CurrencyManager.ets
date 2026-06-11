import { SettingManager } from './SettingManager';

interface CurrencyInfo {
  symbol: string;
  rate: number;
}

const CURRENCIES: Record<string, CurrencyInfo> = {
  '¥': { symbol: '¥', rate: 1.0 },
  '$': { symbol: '$', rate: 0.14 },
  '€': { symbol: '€', rate: 0.13 },
  '£': { symbol: '£', rate: 0.11 }
};

export class CurrencyManager {
  private currentSymbol: string = '¥';
  private loaded: boolean = false;

  public static getInstance(): CurrencyManager {
    if (globalThis.__currencyManager__ == undefined) {
      globalThis.__currencyManager__ = new CurrencyManager();
    }
    return globalThis.__currencyManager__ as CurrencyManager;
  }

  public async init(): Promise<void> {
    if (this.loaded) {
      return;
    }
    try {
      this.currentSymbol = await SettingManager.getInstance().get<string>('currency_unit', '¥');
    } catch (_e) {
      this.currentSymbol = '¥';
    }
    this.loaded = true;
  }

  /** Force reload from preferences (e.g. after settings change) */
  public async reload(): Promise<void> {
    this.loaded = false;
    return this.init();
  }

  public getSymbol(): string {
    return this.currentSymbol;
  }

  /** Directly set symbol (no async read needed, used after saving to Prefs) */
  public setSymbol(symbol: string): void {
    this.currentSymbol = CURRENCIES[symbol] ? symbol : '¥';
    this.loaded = true;
  }

  public convert(cnyAmount: number): number {
    return CurrencyManager.convertWithSymbol(cnyAmount, this.currentSymbol);
  }

  public format(cnyAmount: number): string {
    return CurrencyManager.formatWithSymbol(cnyAmount, this.currentSymbol);
  }

  public static convertWithSymbol(cnyAmount: number, symbol: string): number {
    const info = CURRENCIES[symbol];
    return info ? cnyAmount * info.rate : cnyAmount;
  }

  public static formatWithSymbol(cnyAmount: number, symbol: string): string {
    const info = CURRENCIES[symbol];
    const safeSymbol = info ? info.symbol : '¥';
    const converted = info ? cnyAmount * info.rate : cnyAmount;
    return `${safeSymbol}${converted.toFixed(2)}`;
  }

  public static getCurrencies(): string[] {
    return ['¥', '$', '€', '£'];
  }
}