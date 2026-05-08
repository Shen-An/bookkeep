import promptAction from '@ohos.promptAction';
import { postJson } from './AiHttpClient';
import { AiBillingConfig } from './AiBillingConfig';
import fs from '@ohos.file.fs';

interface ImageRecognitionResult {
  amount?: number;
  direction?: 'IN' | 'OUT';
  category?: string;
  date?: string;
  remark?: string;
}

interface ChatMessage {
  role: string;
  content: string;
}

interface RequestBody {
  model: string;
  temperature: number;
  messages: ChatMessage[];
}

interface OpenAiChoiceMessage {
  content?: string;
}

interface OpenAiChoice {
  message?: OpenAiChoiceMessage;
}

interface OpenAiResponse {
  choices?: OpenAiChoice[];
}

export class ImageProcessor {
  /**
   * 识别图像中的文字并解析为账单信息
   * @param imageUri 图像URI
   * @param config AI配置
   * @param expenseCategories 支出分类列表
   * @param incomeCategories 收入分类列表
   * @returns 识别结果
   */
  public static async recognizeImageText(imageUri: string, config: AiBillingConfig, expenseCategories: string[], incomeCategories: string[]): Promise<string | undefined> {
    try {
      // 读取图像文件
      const file = fs.openSync(imageUri, fs.OpenMode.READ_ONLY);
      const stat = fs.statSync(file.fd);
      const buffer = new ArrayBuffer(stat.size);
      fs.readSync(file.fd, buffer);
      fs.closeSync(file.fd);

      // 将图像转换为base64
      const base64 = bufferToBase64(buffer);

      // 构建请求体
      const messages: ChatMessage[] = [
        {
          role: 'system',
          content: '你是一个记账助手。请仔细分析用户上传的微信截图，提取其中的文字，得到账单信息，并按照JSON格式返回。' +
            '返回的JSON必须包含以下字段：amount(数字，金额), direction("IN"|"OUT", 收支方向), ' +
            'category(string, 分类，必须从给定候选列表中选择), date("YYYY-MM-DD", 日期), remark(string, 备注)。' +
            `支出分类列表：${JSON.stringify(expenseCategories)}` +
            `收入分类列表：${JSON.stringify(incomeCategories)}` +
            '请严格按照JSON格式返回，不要有任何其他文字。'
        },
        {
          role: 'user',
          content: `请分析这张微信截图中的账单信息：![image](data:image/jpeg;base64,${base64})`
        }
      ];

      const body: RequestBody = {
        model: config.model,
        temperature: 0.2,
        messages: messages
      };

      // 构建请求头
      const headers: Record<string, string> = {};
      if (config.apiKeyHeader.toLowerCase() === 'authorization') {
        headers[config.apiKeyHeader] = `${config.apiKeyPrefix}${config.apiKey}`;
      } else {
        headers[config.apiKeyHeader] = config.apiKey;
      }

      // 发送请求
      const resp = await postJson(config.baseUrl, headers, body, config.timeoutMs);
      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        console.error('AI识别失败:', resp.statusCode);
        promptAction.showToast({ message: 'AI识别失败，请重试' });
        return undefined;
      }

      // 解析响应
      const json = JSON.parse(resp.bodyText) as OpenAiResponse;
      const content = json?.choices?.[0]?.message?.content ?? '';
      
      // 提取JSON部分
      const jsonStart = content.indexOf('{');
      const jsonEnd = content.lastIndexOf('}');
      if (jsonStart === -1 || jsonEnd === -1) {
        console.error('AI返回格式错误:', content);
        promptAction.showToast({ message: 'AI返回格式错误，请重试' });
        return undefined;
      }

      const jsonStr = content.substring(jsonStart, jsonEnd + 1);
      return jsonStr;
    } catch (error) {
      console.error('图像识别失败:', error);
      promptAction.showToast({ message: '图像识别失败，请重试' });
      return undefined;
    }
  }

  /**
   * 解析AI返回的响应
   * @param response AI返回的JSON字符串
   * @returns 解析后的账单信息
   */
  public static parseAiResponse(response: string): ImageRecognitionResult {
    try {
      const data: ImageRecognitionResult = JSON.parse(response);
      
      // 处理金额
      let amount: number | undefined;
      if (typeof data.amount === 'number' && data.amount > 0) {
        amount = data.amount;
      }

      // 处理方向
      let direction: 'IN' | 'OUT' | undefined;
      if (data.direction === 'IN' || data.direction === 'OUT') {
        direction = data.direction;
      }

      // 处理分类
      let category: string | undefined;
      if (typeof data.category === 'string' && data.category.trim()) {
        category = data.category.trim();
      }

      // 处理日期
      let date: string | undefined;
      if (typeof data.date === 'string' && data.date.trim()) {
        date = data.date.trim();
      }

      // 处理备注
      let remark: string | undefined;
      if (typeof data.remark === 'string' && data.remark.trim()) {
        remark = data.remark.trim();
      }

      return {
        amount,
        direction,
        category,
        date,
        remark
      };
    } catch (error) {
      console.error('解析AI响应失败:', error);
      promptAction.showToast({ message: '解析AI响应失败，请重试' });
      return {};
    }
  }
}

/**
 * 将ArrayBuffer转换为base64字符串
 * @param buffer ArrayBuffer
 * @returns base64字符串
 */
function bufferToBase64(buffer: ArrayBuffer): string {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
  let result = '';
  const bytes = new Uint8Array(buffer);
  const len = bytes.length;
  
  for (let i = 0; i < len; i += 3) {
    const byte1 = bytes[i];
    const byte2 = i + 1 < len ? bytes[i + 1] : 0;
    const byte3 = i + 2 < len ? bytes[i + 2] : 0;
    
    const enc1 = byte1 >> 2;
    const enc2 = ((byte1 & 3) << 4) | (byte2 >> 4);
    const enc3 = ((byte2 & 15) << 2) | (byte3 >> 6);
    const enc4 = byte3 & 63;

    result += chars.charAt(enc1) + chars.charAt(enc2) + chars.charAt(enc3) + chars.charAt(enc4);
  }
  
  // 处理填充字符
  const padding = len % 3;
  if (padding > 0) {
    const padLength = 3 - padding;
    result = result.substring(0, result.length - padLength);
    for (let i = 0; i < padLength; i++) {
      result += '=';
    }
  }
  
  return result;
}
