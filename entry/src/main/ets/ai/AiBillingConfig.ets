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
 */
export const TEXT_AI_CONFIG: AiBillingConfig = {
  baseUrl: ' ',
  apiKey: ' ',
  model: 'deepseek-v3-2-251201',
  apiKeyHeader: 'Authorization',
  apiKeyPrefix: 'Bearer ',
  timeoutMs: 120_000
};

/**
 * 图像识别AI配置
 */
export const IMAGE_AI_CONFIG: AiBillingConfig = {
  baseUrl: ' ',
  apiKey: ' ',
  model: ' ',
  apiKeyHeader: 'Authorization',
  apiKeyPrefix: 'Bearer ',
  timeoutMs: 120_000
};
