import promptAction from '@ohos.promptAction';
import { postJson } from './AiHttpClient';
import { AiBillingConfig } from './AiBillingConfig';
import fs from '@ohos.file.fs';
import util from '@ohos.util';

interface ImageRecognitionResult {
  amount?: number;
  direction?: 'IN' | 'OUT';
  category?: string;
  date?: string;
  remark?: string;
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

class ChatMessage {
  public role: string = '';
  public content: string = '';

  constructor(role: string, content: string) {
    this.role = role;
    this.content = content;
  }
}

class ImageContentPart {
  public type: string = 'image_url';
  public image_url: ImageUrl = new ImageUrl('');

  constructor(type: string, imageUrl: ImageUrl) {
    this.type = type;
    this.image_url = imageUrl;
  }
}

class TextContentPart {
  public type: string = 'text';
  public text: string = '';

  constructor(type: string, text: string) {
    this.type = type;
    this.text = text;
  }
}

class ImageUrl {
  public url: string = '';

  constructor(url: string) {
    this.url = url;
  }
}

class VisionChatMessage {
  public role: string = '';
  public content: Object[] = [];

  constructor(role: string, content: Object[]) {
    this.role = role;
    this.content = content;
  }
}

class RequestBody {
  public model: string = '';
  public temperature: number = 0;
  public messages: Object[] = [];

  constructor(model: string, temperature: number, messages: Object[]) {
    this.model = model;
    this.temperature = temperature;
    this.messages = messages;
  }
}

export class ImageProcessor {
  /**
   * 识别图像中的文字并解析为账单信息
   * 流程：将图片转为base64 → 发送给支持视觉的AI模型识别
   * @param imageUri 图像URI
   * @param config AI配置（需使用支持视觉识别的模型，如GLM-4V）
   * @param expenseCategories 支出分类列表
   * @param incomeCategories 收入分类列表
   * @returns 识别结果
   */
  public static async recognizeImageText(imageUri: string, config: AiBillingConfig, expenseCategories: string[], incomeCategories: string[]): Promise<string | undefined> {
    try {
      // 第一步：读取图片并转为base64
      promptAction.showToast({ message: '正在处理图片...' });
      const base64Image: string = await ImageProcessor.imageToBase64(imageUri);
      const mimeType: string = ImageProcessor.getMimeType(imageUri);
      const dataUrl: string = `data:${mimeType};base64,${base64Image}`;

      // 第二步：将图片发送给支持视觉的AI模型识别
      promptAction.showToast({ message: '正在识别图片内容...' });
      const result = await ImageProcessor.recognizeWithVisionAI(dataUrl, config, expenseCategories, incomeCategories);
      return result;
    } catch (error) {
      const err: Error = error as Error;
      console.error('图像识别失败:', err.message);
      promptAction.showToast({ message: '图像识别失败，请重试' });
      return undefined;
    }
  }

  /**
   * 获取图片文件的MIME类型
   */
  private static getMimeType(uri: string): string {
    const lower: string = uri.toLowerCase();
    if (lower.endsWith('.png')) {
      return 'image/png';
    }
    if (lower.endsWith('.webp')) {
      return 'image/webp';
    }
    if (lower.endsWith('.bmp')) {
      return 'image/bmp';
    }
    return 'image/jpeg';
  }

  /**
   * 将图片文件转为base64字符串
   * @param imageUri 图片文件路径
   * @returns base64编码的图片数据
   */
  private static async imageToBase64(imageUri: string): Promise<string> {
    // 读取文件
    const file = fs.openSync(imageUri, fs.OpenMode.READ_ONLY);
    const stat = fs.statSync(file.fd);
    const buffer = new ArrayBuffer(stat.size);
    fs.readSync(file.fd, buffer);
    fs.closeSync(file.fd);

    // 使用util.Base64Helper编码
    const base64Helper = new util.Base64Helper();
    const uint8Array: Uint8Array = new Uint8Array(buffer);
    const base64Str: string = base64Helper.encodeToStringSync(uint8Array);

    return base64Str;
  }

  /**
   * 使用支持视觉识别的AI模型识别图片
   * @param dataUrl 图片的data URL（data:image/xxx;base64,xxx）
   * @param config AI配置
   * @param expenseCategories 支出分类列表
   * @param incomeCategories 收入分类列表
   * @returns AI返回的JSON字符串
   */
  private static async recognizeWithVisionAI(dataUrl: string, config: AiBillingConfig, expenseCategories: string[], incomeCategories: string[]): Promise<string | undefined> {
    const systemMessage: VisionChatMessage = new VisionChatMessage(
      'system',
      [new TextContentPart('text',
        '你是一个专业的微信/支付宝账单信息解析工具。你的任务是从图片中提取账单信息。\n\n' +
        '规则（严格遵守）：\n' +
        '1. 金额(amount)：必须是一个数字（正数），例如 12.50、168.00。如果看到"¥"或"￥"符号后面的数字就是金额。\n' +
        '2. 方向(direction)：支付/付款/转账给别人→"OUT"；收款/到账/退款→"IN"。\n' +
        '3. 分类(category)：**必须**从下方分类列表中选择最匹配的一项，**不要设为null**！根据商户名称推断：\n' +
        '   - 拼多多、淘宝、京东、超市→"购物"\n' +
        '   - 奶茶、咖啡、餐厅、外卖→"餐饮"\n' +
        '   - 打车、地铁、公交、加油→"交通"\n' +
        '   - 药店、医院→"医疗"\n' +
        '4. 日期(date)：从图片中提取交易日期，格式"YYYY-MM-DD"。如果看不到日期，设为null。\n' +
        '5. 备注(remark)：写商户名称即可，如"拼多多"、"星巴克"。\n\n' +
        '⚠️ 金额不要加负号，始终返回正数。\n' +
        '⚠️ 只输出JSON，不要输出任何解释、描述或markdown。\n\n' +
        `支出分类列表：${JSON.stringify(expenseCategories)}\n` +
        `收入分类列表：${JSON.stringify(incomeCategories)}\n\n` +
        '输出格式：{"amount": number, "direction": "IN"|"OUT", "category": string, "date": "YYYY-MM-DD"|null, "remark": string}'
      )]
    );

    const userMessage: VisionChatMessage = new VisionChatMessage(
      'user',
      [
        new TextContentPart('text', '请识别这张微信/支付宝账单截图中的交易信息，严格按照分类列表选择分类，输出JSON：'),
        new ImageContentPart('image_url', new ImageUrl(dataUrl))
      ]
    );

    const messages: Object[] = [
      systemMessage,
      userMessage
    ];

    const body: RequestBody = new RequestBody(config.model, 0, messages);

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
      console.error('AI识别失败:', resp.statusCode, resp.bodyText);
      promptAction.showToast({ message: 'AI识别失败，请重试' });
      return undefined;
    }

    // 解析响应
    console.info('AI原始响应:', resp.bodyText);
    const json: OpenAiResponse = JSON.parse(resp.bodyText) as OpenAiResponse;
    const content: string = json?.choices?.[0]?.message?.content ?? '';
    console.info('AI返回内容:', content);

    // 提取JSON部分
    const jsonStart: number = content.indexOf('{');
    const jsonEnd: number = content.lastIndexOf('}');
    if (jsonStart === -1 || jsonEnd === -1) {
      console.error('AI返回格式错误:', content);
      promptAction.showToast({ message: 'AI返回格式错误，请重试' });
      return undefined;
    }

    const jsonStr: string = content.substring(jsonStart, jsonEnd + 1);
    console.info('提取的JSON:', jsonStr);
    return jsonStr;
  }

  /**
   * 解析AI返回的响应，并进行合理性校验
   * @param response AI返回的JSON字符串
   * @returns 解析后的账单信息
   */
  public static parseAiResponse(response: string): ImageRecognitionResult {
    try {
      const data: ImageRecognitionResult = JSON.parse(response);

      // 处理金额 - 增加合理性校验，兼容数字和字符串格式
      let amount: number | undefined;
      let rawAmount: number | undefined;
      if (typeof data.amount === 'number') {
        rawAmount = data.amount;
      } else if (typeof data.amount === 'string') {
        const parsed = parseFloat(data.amount);
        if (!isNaN(parsed)) {
          rawAmount = parsed;
        }
      }
      if (rawAmount !== undefined && rawAmount !== 0) {
        // 金额合理性校验：取绝对值后判断，通常微信支付金额在 0.01 ~ 999999 之间
        const absAmount = Math.abs(rawAmount);
        if (absAmount >= 0.01 && absAmount <= 999999) {
          amount = absAmount;
        } else {
          console.warn('AI返回的金额不合理:', rawAmount);
          amount = undefined;
        }
      }

      // 处理方向
      let direction: 'IN' | 'OUT' | undefined;
      if (data.direction === 'IN' || data.direction === 'OUT') {
        direction = data.direction;
      }

      // 处理分类 - 如果AI返回了不合理的分类名称，设为undefined
      let category: string | undefined;
      if (typeof data.category === 'string' && data.category.trim()) {
        const cat: string = data.category.trim();
        // 过滤掉明显不是分类的文本（如商户名称、描述性文字）
        const invalidCategories: string[] = ['美团外卖', '公司食堂', '商户', '商家', '微信', '支付宝', '转账', '付款', '收款'];
        if (!invalidCategories.includes(cat)) {
          category = cat;
        }
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

      const result: ImageRecognitionResult = {
        amount: amount,
        direction: direction,
        category: category,
        date: date,
        remark: remark
      };
      return result;
    } catch (error) {
      const err: Error = error as Error;
      console.error('解析AI响应失败:', err.message);
      promptAction.showToast({ message: '解析AI响应失败，请重试' });
      const emptyResult: ImageRecognitionResult = {};
      return emptyResult;
    }
  }
}