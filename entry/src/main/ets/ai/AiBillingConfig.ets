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
  baseUrl: '',
  apiKey: '',
  model: 'gpt-4.1-mini',
  apiKeyHeader: 'Authorization',
  apiKeyPrefix: 'Bearer ',
  timeoutMs: 60_000
};
