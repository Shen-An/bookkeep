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
  baseUrl: 'https://open.bigmodel.cn/api/paas/v4/chat/completions',
  apiKey: '33829b6e4fc84a6ea6e27f13468ea7fc.43DCuGO2fSDiQLGQ',
  model: 'glm-4.5-air',
  apiKeyHeader: 'Authorization',
  apiKeyPrefix: 'Bearer ',
  timeoutMs: 120_000
};

/**
 * 图像识别AI配置
 * 使用智谱 GLM-4V-Flash（支持视觉识别，免费）
 * 将图片转为base64发送给视觉模型识别
 */
export const IMAGE_AI_CONFIG: AiBillingConfig = {
  baseUrl: 'https://open.bigmodel.cn/api/paas/v4/chat/completions',
  apiKey: '33829b6e4fc84a6ea6e27f13468ea7fc.43DCuGO2fSDiQLGQ',
  model: 'glm-4v-flash',
  apiKeyHeader: 'Authorization',
  apiKeyPrefix: 'Bearer ',
  timeoutMs: 120_000
};
