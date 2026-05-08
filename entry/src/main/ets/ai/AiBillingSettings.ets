import { SettingManager } from '@ohos/common';
import { AI_BILLING_CONFIG, AiBillingConfig } from './AiBillingConfig';

const KEY_BASE_URL = 'ai.billing.baseUrl';
const KEY_API_KEY = 'ai.billing.apiKey';
const KEY_MODEL = 'ai.billing.model';
const KEY_API_KEY_HEADER = 'ai.billing.apiKeyHeader';
const KEY_API_KEY_PREFIX = 'ai.billing.apiKeyPrefix';
const KEY_TIMEOUT_MS = 'ai.billing.timeoutMs';

export interface AiBillingStoredConfig {
  baseUrl: string;
  apiKey: string;
  model: string;
  apiKeyHeader: string;
  apiKeyPrefix: string;
  timeoutMs: number;
}

export class AiBillingSettings {
  public static async load(context?: Context): Promise<AiBillingStoredConfig> {
    const sm = SettingManager.getInstance(context);
    const baseUrl = await sm.get<string>(KEY_BASE_URL, AI_BILLING_CONFIG.baseUrl);
    const apiKey = await sm.get<string>(KEY_API_KEY, AI_BILLING_CONFIG.apiKey);
    const model = await sm.get<string>(KEY_MODEL, AI_BILLING_CONFIG.model);
    const apiKeyHeader = await sm.get<string>(KEY_API_KEY_HEADER, AI_BILLING_CONFIG.apiKeyHeader);
    const apiKeyPrefix = await sm.get<string>(KEY_API_KEY_PREFIX, AI_BILLING_CONFIG.apiKeyPrefix);
    const timeoutMs = await sm.get<number>(KEY_TIMEOUT_MS, AI_BILLING_CONFIG.timeoutMs);

    return {
      baseUrl: (baseUrl ?? '').trim(),
      apiKey: (apiKey ?? '').trim(),
      model: (model ?? '').trim() || AI_BILLING_CONFIG.model,
      apiKeyHeader: (apiKeyHeader ?? '').trim() || 'Authorization',
      apiKeyPrefix: (apiKeyPrefix ?? '').trim(),
      timeoutMs: (typeof timeoutMs === 'number' && timeoutMs > 0) ? timeoutMs : AI_BILLING_CONFIG.timeoutMs
    };
  }

  public static save(context: Context | undefined, cfg: Partial<AiBillingConfig>) {
    const sm = SettingManager.getInstance(context);
    if (typeof cfg.baseUrl === 'string') sm.set(KEY_BASE_URL, cfg.baseUrl.trim());
    if (typeof cfg.apiKey === 'string') sm.set(KEY_API_KEY, cfg.apiKey.trim());
    if (typeof cfg.model === 'string') sm.set(KEY_MODEL, cfg.model.trim());
    if (typeof cfg.apiKeyHeader === 'string') sm.set(KEY_API_KEY_HEADER, cfg.apiKeyHeader.trim());
    if (typeof cfg.apiKeyPrefix === 'string') sm.set(KEY_API_KEY_PREFIX, cfg.apiKeyPrefix);
    if (typeof cfg.timeoutMs === 'number') sm.set(KEY_TIMEOUT_MS, cfg.timeoutMs);
  }

  public static applyToRuntimeConfig(stored: AiBillingStoredConfig) {
    AI_BILLING_CONFIG.baseUrl = stored.baseUrl;
    AI_BILLING_CONFIG.apiKey = stored.apiKey;
    AI_BILLING_CONFIG.model = stored.model;
    AI_BILLING_CONFIG.apiKeyHeader = stored.apiKeyHeader;
    AI_BILLING_CONFIG.apiKeyPrefix = stored.apiKeyPrefix;
    AI_BILLING_CONFIG.timeoutMs = stored.timeoutMs;
  }

  public static async loadAndApply(context?: Context): Promise<AiBillingStoredConfig> {
    const stored = await this.load(context);
    this.applyToRuntimeConfig(stored);
    return stored;
  }
}
