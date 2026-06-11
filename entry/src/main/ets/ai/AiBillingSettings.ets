import { SettingManager } from '@ohos/common';
import { TEXT_AI_CONFIG, IMAGE_AI_CONFIG, AiBillingConfig } from './AiBillingConfig';
import router from '@ohos.router';

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

// ──── AI 配置页面（可路由）────────

@Entry
@Component
export struct AiBillingSettingsPage {
  @State textBaseUrl: string = '';
  @State textApiKey: string = '';

  @State imageBaseUrl: string = '';
  @State imageApiKey: string = '';

  @State saving: boolean = false;
  @State saved: boolean = false;

  aboutToAppear() {
    this.loadConfigs();
  }

  private loadConfigs() {
    AiBillingSettings.loadText(getContext()).then((cfg: AiBillingTextStoredConfig) => {
      this.textBaseUrl = cfg.baseUrl;
      this.textApiKey = cfg.apiKey;
    }).catch(() => {});
    AiBillingSettings.loadImage(getContext()).then((cfg: AiBillingImageStoredConfig) => {
      this.imageBaseUrl = cfg.baseUrl;
      this.imageApiKey = cfg.apiKey;
    }).catch(() => {});
  }

  private saveConfigs() {
    this.saving = true;
    this.saved = false;
    AiBillingSettings.saveText(getContext(), {
      baseUrl: this.textBaseUrl,
      apiKey: this.textApiKey,
      model: TEXT_AI_CONFIG.model,
      apiKeyHeader: TEXT_AI_CONFIG.apiKeyHeader,
      apiKeyPrefix: TEXT_AI_CONFIG.apiKeyPrefix,
      timeoutMs: TEXT_AI_CONFIG.timeoutMs
    });
    AiBillingSettings.saveImage(getContext(), {
      baseUrl: this.imageBaseUrl,
      apiKey: this.imageApiKey,
      model: IMAGE_AI_CONFIG.model,
      apiKeyHeader: IMAGE_AI_CONFIG.apiKeyHeader,
      apiKeyPrefix: IMAGE_AI_CONFIG.apiKeyPrefix,
      timeoutMs: IMAGE_AI_CONFIG.timeoutMs
    });
    // Apply to runtime config
    AiBillingSettings.loadAndApplyText(getContext());
    AiBillingSettings.loadAndApplyImage(getContext());
    this.saving = false;
    this.saved = true;
    setTimeout(() => { this.saved = false; }, 2000);
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Button({ type: ButtonType.Normal }) {
          Text('←')
            .fontSize(22)
            .fontColor(Color.White)
        }
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          router.back();
        })

        Text($r('app.string.settings_ai_config'))
          .fontColor(Color.White)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .layoutWeight(1)
          .margin({ right: 40 })
      }
      .padding({ top: 28, bottom: 16, left: 8, right: 8 })
      .width('100%')
      .linearGradient({
        angle: 180,
        colors: [
          [$r('app.color.main_theme_gradient_start'), 0],
          [$r('app.color.main_theme_gradient_end'), 1]
        ]
      })

      Scroll() {
        Column() {
          // 文字 AI 配置
          Column() {
            Row() {
              Text('文字识别 AI')
                .fontSize(13)
                .fontColor('#999999')
                .fontWeight(FontWeight.Medium)
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 16, bottom: 8 })

            Column() {
              this.settingInput('Base URL', this.textBaseUrl, (v: string) => { this.textBaseUrl = v; })
              Divider().opacity(0.1).width('92%').margin({ left: 12 })
              this.settingInput('API Key', this.textApiKey, (v: string) => { this.textApiKey = v; }, true)
            }
            .width('100%')
            .backgroundColor(Color.White)
            .borderRadius(12)
            .padding({ left: 4, right: 4 })
          }
          .width('100%')

          // 图片 AI 配置
          Column() {
            Row() {
              Text('图片识别 AI')
                .fontSize(13)
                .fontColor('#999999')
                .fontWeight(FontWeight.Medium)
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 20, bottom: 8 })

            Column() {
              this.settingInput('Base URL', this.imageBaseUrl, (v: string) => { this.imageBaseUrl = v; })
              Divider().opacity(0.1).width('92%').margin({ left: 12 })
              this.settingInput('API Key', this.imageApiKey, (v: string) => { this.imageApiKey = v; }, true)
            }
            .width('100%')
            .backgroundColor(Color.White)
            .borderRadius(12)
            .padding({ left: 4, right: 4 })
          }
          .width('100%')

          // 保存按钮
          Row() {
            Button({ type: ButtonType.Capsule }) {
              if (this.saved) {
                Text('✓ 已保存')
                  .fontColor(Color.White)
                  .fontSize(15)
              } else {
                Text(this.saving ? '保存中...' : '保存配置')
                  .fontColor(Color.White)
                  .fontSize(15)
              }
            }
            .width(200)
            .height(40)
            .backgroundColor(this.saved ? '#4CAF50' : '#4a7dff')
            .onClick(() => {
              if (!this.saving && !this.saved) {
                this.saveConfigs();
              }
            })
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .margin({ top: 24, bottom: 32 })
        }
        .width('100%')
        .padding({ left: 12, right: 12 })
      }
      .layoutWeight(1)
      .width('100%')
    }
    .height('100%')
    .width('100%')
    .backgroundColor($r('app.color.page_background'))
  }

  @Builder settingInput(label: string, value: string, onChange: (v: string) => void, isPassword: boolean = false) {
    Row() {
      Text(label)
        .fontSize(13)
        .fontColor('#666666')
        .width(90)

      if (isPassword) {
        TextInput({ text: value })
          .fontSize(14)
          .layoutWeight(1)
          .type(InputType.Password)
          .onChange(onChange)
          .placeholderColor('#cccccc')
          .placeholderFont({ size: 14 })
      } else {
        TextInput({ text: value })
          .fontSize(14)
          .layoutWeight(1)
          .onChange(onChange)
          .placeholderColor('#cccccc')
          .placeholderFont({ size: 14 })
      }
    }
    .width('100%')
    .padding({ left: 12, right: 12, top: 10, bottom: 10 })
  }
}
