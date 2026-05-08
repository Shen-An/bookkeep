import { SettingManager } from '@ohos/common';
import { TEXT_AI_CONFIG, IMAGE_AI_CONFIG, AiBillingConfig } from './AiBillingConfig';

// Keys for Text AI Config
const KEY_TEXT_BASE_URL = 'ai.billing.text.baseUrl';
const KEY_TEXT_API_KEY = 'ai.billing.text.apiKey';
const KEY_TEXT_MODEL = 'ai.billing.text.model';
const KEY_TEXT_API_KEY_HEADER = 'ai.billing.text.apiKeyHeader';
const KEY_TEXT_API_KEY_PREFIX = 'ai.billing.text.apiKeyPrefix';
const KEY_TEXT_TIMEOUT_MS = 'ai.billing.text.timeoutMs';

// Keys for Image AI Config
const KEY_IMAGE_BASE_URL = 'ai.billing.image.baseUrl';
const KEY_IMAGE_API_KEY = 'ai.billing.image.apiKey';
const KEY_IMAGE_MODEL = 'ai.billing.image.model';
const KEY_IMAGE_API_KEY_HEADER = 'ai.billing.image.apiKeyHeader';
const KEY_IMAGE_API_KEY_PREFIX = 'ai.billing.image.apiKeyPrefix';
const KEY_IMAGE_TIMEOUT_MS = 'ai.billing.image.timeoutMs';

export interface AiBillingTextStoredConfig {
  baseUrl: string;
  apiKey: string;
  model: string;
  apiKeyHeader: string;
  apiKeyPrefix: string;
  timeoutMs: number;
}

export interface AiBillingImageStoredConfig {
  baseUrl: string;
  apiKey: string;
  model: string;
  apiKeyHeader: string;
  apiKeyPrefix: string;
  timeoutMs: number;
}

export class AiBillingSettings {
  public static async loadText(context?: Context): Promise<AiBillingTextStoredConfig> {
    const sm = SettingManager.getInstance(context);
    const baseUrl = await sm.get<string>(KEY_TEXT_BASE_URL, TEXT_AI_CONFIG.baseUrl);
    const apiKey = await sm.get<string>(KEY_TEXT_API_KEY, TEXT_AI_CONFIG.apiKey);
    const model = await sm.get<string>(KEY_TEXT_MODEL, TEXT_AI_CONFIG.model);
    const apiKeyHeader = await sm.get<string>(KEY_TEXT_API_KEY_HEADER, TEXT_AI_CONFIG.apiKeyHeader);
    const apiKeyPrefix = await sm.get<string>(KEY_TEXT_API_KEY_PREFIX, TEXT_AI_CONFIG.apiKeyPrefix);
    const timeoutMs = await sm.get<number>(KEY_TEXT_TIMEOUT_MS, TEXT_AI_CONFIG.timeoutMs);

    return {
      baseUrl: (baseUrl ?? '').trim(),
      apiKey: (apiKey ?? '').trim(),
      model: (model ?? '').trim() || TEXT_AI_CONFIG.model,
      apiKeyHeader: (apiKeyHeader ?? '').trim() || TEXT_AI_CONFIG.apiKeyHeader,
      apiKeyPrefix: (apiKeyPrefix ?? '').trim(),
      timeoutMs: (typeof timeoutMs === 'number' && timeoutMs > 0) ? timeoutMs : TEXT_AI_CONFIG.timeoutMs
    };
  }

  public static async loadImage(context?: Context): Promise<AiBillingImageStoredConfig> {
    const sm = SettingManager.getInstance(context);
    const baseUrl = await sm.get<string>(KEY_IMAGE_BASE_URL, IMAGE_AI_CONFIG.baseUrl);
    const apiKey = await sm.get<string>(KEY_IMAGE_API_KEY, IMAGE_AI_CONFIG.apiKey);
    const model = await sm.get<string>(KEY_IMAGE_MODEL, IMAGE_AI_CONFIG.model);
    const apiKeyHeader = await sm.get<string>(KEY_IMAGE_API_KEY_HEADER, IMAGE_AI_CONFIG.apiKeyHeader);
    const apiKeyPrefix = await sm.get<string>(KEY_IMAGE_API_KEY_PREFIX, IMAGE_AI_CONFIG.apiKeyPrefix);
    const timeoutMs = await sm.get<number>(KEY_IMAGE_TIMEOUT_MS, IMAGE_AI_CONFIG.timeoutMs);

    return {
      baseUrl: (baseUrl ?? '').trim(),
      apiKey: (apiKey ?? '').trim(),
      model: (model ?? '').trim() || IMAGE_AI_CONFIG.model,
      apiKeyHeader: (apiKeyHeader ?? '').trim() || IMAGE_AI_CONFIG.apiKeyHeader,
      apiKeyPrefix: (apiKeyPrefix ?? '').trim(),
      timeoutMs: (typeof timeoutMs === 'number' && timeoutMs > 0) ? timeoutMs : IMAGE_AI_CONFIG.timeoutMs
    };
  }

  public static saveText(context: Context | undefined, cfg: Partial<AiBillingConfig>) {
    const sm = SettingManager.getInstance(context);
    if (typeof cfg.baseUrl === 'string') sm.set(KEY_TEXT_BASE_URL, cfg.baseUrl.trim());
    if (typeof cfg.apiKey === 'string') sm.set(KEY_TEXT_API_KEY, cfg.apiKey.trim());
    if (typeof cfg.model === 'string') sm.set(KEY_TEXT_MODEL, cfg.model.trim());
    if (typeof cfg.apiKeyHeader === 'string') sm.set(KEY_TEXT_API_KEY_HEADER, cfg.apiKeyHeader.trim());
    if (typeof cfg.apiKeyPrefix === 'string') sm.set(KEY_TEXT_API_KEY_PREFIX, cfg.apiKeyPrefix);
    if (typeof cfg.timeoutMs === 'number') sm.set(KEY_TEXT_TIMEOUT_MS, cfg.timeoutMs);
  }

  public static saveImage(context: Context | undefined, cfg: Partial<AiBillingConfig>) {
    const sm = SettingManager.getInstance(context);
    if (typeof cfg.baseUrl === 'string') sm.set(KEY_IMAGE_BASE_URL, cfg.baseUrl.trim());
    if (typeof cfg.apiKey === 'string') sm.set(KEY_IMAGE_API_KEY, cfg.apiKey.trim());
    if (typeof cfg.model === 'string') sm.set(KEY_IMAGE_MODEL, cfg.model.trim());
    if (typeof cfg.apiKeyHeader === 'string') sm.set(KEY_IMAGE_API_KEY_HEADER, cfg.apiKeyHeader.trim());
    if (typeof cfg.apiKeyPrefix === 'string') sm.set(KEY_IMAGE_API_KEY_PREFIX, cfg.apiKeyPrefix);
    if (typeof cfg.timeoutMs === 'number') sm.set(KEY_IMAGE_TIMEOUT_MS, cfg.timeoutMs);
  }

  public static applyTextToRuntimeConfig(stored: AiBillingTextStoredConfig) {
    TEXT_AI_CONFIG.baseUrl = stored.baseUrl;
    TEXT_AI_CONFIG.apiKey = stored.apiKey;
    TEXT_AI_CONFIG.model = stored.model;
    TEXT_AI_CONFIG.apiKeyHeader = stored.apiKeyHeader;
    TEXT_AI_CONFIG.apiKeyPrefix = stored.apiKeyPrefix;
    TEXT_AI_CONFIG.timeoutMs = stored.timeoutMs;
  }

  public static applyImageToRuntimeConfig(stored: AiBillingImageStoredConfig) {
    IMAGE_AI_CONFIG.baseUrl = stored.baseUrl;
    IMAGE_AI_CONFIG.apiKey = stored.apiKey;
    IMAGE_AI_CONFIG.model = stored.model;
    IMAGE_AI_CONFIG.apiKeyHeader = stored.apiKeyHeader;
    IMAGE_AI_CONFIG.apiKeyPrefix = stored.apiKeyPrefix;
    IMAGE_AI_CONFIG.timeoutMs = stored.timeoutMs;
  }

  public static async loadAndApplyText(context?: Context): Promise<AiBillingTextStoredConfig> {
    const stored = await AiBillingSettings.loadText(context);      // 使用类名代替 this
    AiBillingSettings.applyTextToRuntimeConfig(stored);            // 使用类名代替 this
    return stored;
  }

  public static async loadAndApplyImage(context?: Context): Promise<AiBillingImageStoredConfig> {
    const stored = await AiBillingSettings.loadImage(context);
    AiBillingSettings.applyImageToRuntimeConfig(stored);
    return stored;
  }
}
