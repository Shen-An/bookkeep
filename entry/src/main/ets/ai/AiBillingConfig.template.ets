export interface AiBillingConfig {
  /**
   * OpenAI-compatible Chat Completions endpoint.
   * Example: https://api.openai.com/v1/chat/completions
   */
  baseUrl: string;
  /** Provider API key */
  apiKey: string;
  /** Model name for chat completion */
  model: string;
  /**
   * Auth header name.
   * - Typical OpenAI: Authorization: Bearer <key>
   * - Some providers: api-key: <key>
   */
  apiKeyHeader: string;
  /** Optional prefix, e.g. "Bearer " */
  apiKeyPrefix: string;
  /** Request timeout in ms */
  timeoutMs: number;
}

/**
 * 文字识别AI配置
 * ⚠️ 请复制此文件为 AiBillingConfig.ets 并填入你的真实 API Key
 * AiBillingConfig.ets 已在 .gitignore 中，不会被提交到仓库
 */
export const TEXT_AI_CONFIG: AiBillingConfig = {
  baseUrl: 'https://api.openai.com/v1/chat/completions',
  apiKey: 'YOUR_TEXT_API_KEY_HERE',
  model: 'gpt-4o-mini',
  apiKeyHeader: 'Authorization',
  apiKeyPrefix: 'Bearer ',
  timeoutMs: 120_000
};

/**
 * 图像识别AI配置
 * ⚠️ 请复制此文件为 AiBillingConfig.ets 并填入你的真实 API Key
 * AiBillingConfig.ets 已在 .gitignore 中，不会被提交到仓库
 */
export const IMAGE_AI_CONFIG: AiBillingConfig = {
  baseUrl: 'https://api.openai.com/v1/chat/completions',
  apiKey: 'YOUR_IMAGE_API_KEY_HERE',
  model: 'gpt-4o-mini',
  apiKeyHeader: 'Authorization',
  apiKeyPrefix: 'Bearer ',
  timeoutMs: 120_000
};