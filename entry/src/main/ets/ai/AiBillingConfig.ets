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
 * IMPORTANT:
 * - Do NOT commit real secrets.
 * - Fill these locally for your environment.
 */
export const AI_BILLING_CONFIG: AiBillingConfig = {
  baseUrl: 'https://open.bigmodel.cn/api/paas/v4/chat/completions',
  apiKey: '33829b6e4fc84a6ea6e27f13468ea7fc.43DCuGO2fSDiQLGQ',
  model: 'GLM-4.7-Flash',
  apiKeyHeader: 'Authorization',
  apiKeyPrefix: 'Bearer ',
  timeoutMs: 60_000
};
