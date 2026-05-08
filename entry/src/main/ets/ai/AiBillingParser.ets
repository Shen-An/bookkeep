import { BillingDirection, BillingInfo, BillingType } from '@ohos/common';
import { TEXT_AI_CONFIG, AiBillingConfig } from './AiBillingConfig';
import { postJson } from './AiHttpClient';

export interface BillTypeOption {
  title: string;
  img: Resource;
}

export type MissingField = 'amount' | 'direction' | 'category' | 'date';

export interface AiParseSuccess {
  ok: true;
  bill: BillingInfo;
  used: 'rule' | 'llm' | 'hybrid';
  summary: string;
}

export interface AiParseFailure {
  ok: false;
  tip: string;
  missing: MissingField[];
  used: 'rule' | 'llm' | 'hybrid';
}

export type AiParseResult = AiParseSuccess | AiParseFailure;

export interface AiParseOptions {
  now?: Date;
  expenseTypes: BillTypeOption[];
  incomeTypes: BillTypeOption[];
  preferLLM?: boolean;
  config?: Partial<AiBillingConfig>;
}

interface RuleParsed {
  amount?: number;
  direction?: BillingDirection;
  categoryName?: string;
  date?: Date;
  remark?: string;
  confidence: number;
}

interface LlmParsed {
  amount?: number;
  direction?: 'IN' | 'OUT';
  category?: string;
  date?: string;
  remark?: string;
  needMoreInfo?: boolean;
  missingFields?: string[];
  friendlyTip?: string;
}

interface MergedRuleParsed extends RuleParsed {
  used: 'rule' | 'llm' | 'hybrid';
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
// 定义简单类型，避免匿名对象字面量类型
interface ScoreValue {
  value: number;
  score: number;
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

function normalizeText(input: string): string {
  const trimmed = (input ?? '').trim();
  if (!trimmed) return '';
  return trimmed
    .replace(/\u3000/g, ' ')
    .replace(/，/g, ',')
    .replace(/。/g, '.')
    .replace(/￥/g, '¥')
    .replace(/（/g, '(')
    .replace(/）/g, ')')
    .replace(/\s+/g, ' ')
    .trim();
}

function ymd(date: Date): string {
  const y = date.getFullYear();
  const m = (date.getMonth() + 1).toString().padStart(2, '0');
  const d = date.getDate().toString().padStart(2, '0');
  return `${y}-${m}-${d}`;
}

function parseYmd(s: string, now: Date): Date | undefined {
  const str = (s ?? '').trim();
  if (!str) return undefined;
  const m1 = str.match(/^(\d{4})-(\d{1,2})-(\d{1,2})$/);
  if (m1) {
    const y = parseInt(m1[1], 10);
    const mo = parseInt(m1[2], 10);
    const d = parseInt(m1[3], 10);
    if (!Number.isNaN(y) && mo >= 1 && mo <= 12 && d >= 1 && d <= 31) {
      return new Date(y, mo - 1, d);
    }
  }
  const m2 = str.match(/^(\d{1,2})[\/-](\d{1,2})$/);
  if (m2) {
    const mo = parseInt(m2[1], 10);
    const d = parseInt(m2[2], 10);
    if (mo >= 1 && mo <= 12 && d >= 1 && d <= 31) {
      return new Date(now.getFullYear(), mo - 1, d);
    }
  }
  return undefined;
}

function shiftDate(now: Date, deltaDays: number): Date {
  const d = new Date(now.getTime());
  d.setDate(d.getDate() + deltaDays);
  return d;
}

function tryParseRelativeDate(text: string, now: Date): Date | undefined {
  const t = text.toLowerCase();
  if (t.includes('今天') || t.includes('today')) return new Date(now.getTime());
  if (t.includes('昨天') || t.includes('yesterday')) return shiftDate(now, -1);
  if (t.includes('前天')) return shiftDate(now, -2);
  if (t.includes('明天') || t.includes('tomorrow')) return shiftDate(now, 1);
  if (t.includes('后天')) return shiftDate(now, 2);
  if (t.includes('昨晚') || t.includes('昨天晚上') || t.includes('last night')) return shiftDate(now, -1);
  return undefined;
}

function tryParseExplicitDate(text: string, now: Date): Date | undefined {
  const ymdMatch = text.match(/(\d{4})[\/.\-](\d{1,2})[\/.\-](\d{1,2})/);
  if (ymdMatch) {
    return parseYmd(`${ymdMatch[1]}-${ymdMatch[2]}-${ymdMatch[3]}`, now);
  }
  const mdMatch = text.match(/\b(\d{1,2})[\/.\-](\d{1,2})\b/);
  if (mdMatch) {
    const parsed = parseYmd(`${mdMatch[1]}/${mdMatch[2]}`, now);
    if (parsed) return parsed;
  }
  const zhMatch = text.match(/(\d{1,2})\s*月\s*(\d{1,2})\s*[日号]?/);
  if (zhMatch) {
    const mo = parseInt(zhMatch[1], 10);
    const d = parseInt(zhMatch[2], 10);
    if (mo >= 1 && mo <= 12 && d >= 1 && d <= 31) {
      return new Date(now.getFullYear(), mo - 1, d);
    }
  }
  return undefined;
}

// 使用 Map 避免 hasOwnProperty 问题
const CN_NUM_MAP: Map<string, number> = new Map([
  ['零', 0], ['一', 1], ['二', 2], ['两', 2],
  ['三', 3], ['四', 4], ['五', 5], ['六', 6],
  ['七', 7], ['八', 8], ['九', 9]
]);

function parseChineseInteger(input: string): number | undefined {
  let str = (input ?? '').trim();
  if (!str) return undefined;
  if (!/[零一二两三四五六七八九十百千万]/.test(str)) return undefined;

  let total = 0;
  let section = 0;
  let num = 0;

  const pushNum = () => {
    section += num;
    num = 0;
  };

  for (const ch of str) {
    if (CN_NUM_MAP.has(ch)) {
      num = CN_NUM_MAP.get(ch)!;
      continue;
    }
    if (ch === '十') {
      if (num === 0) num = 1;
      section += num * 10;
      num = 0;
      continue;
    }
    if (ch === '百') {
      if (num === 0) num = 1;
      section += num * 100;
      num = 0;
      continue;
    }
    if (ch === '千') {
      if (num === 0) num = 1;
      section += num * 1000;
      num = 0;
      continue;
    }
    if (ch === '万') {
      pushNum();
      total += section * 10000;
      section = 0;
      continue;
    }
  }
  pushNum();
  total += section;
  if (Number.isFinite(total) && total > 0) return total;
  return undefined;
}

function removeDateFragments(text: string): string {
  return text
    .replace(/\d{4}[\/.\-]\d{1,2}[\/.\-]\d{1,2}/g, ' ')
    .replace(/\b\d{1,2}[\/.\-]\d{1,2}\b/g, ' ')
    .replace(/\d{1,2}\s*月\s*\d{1,2}\s*[日号]?/g, ' ');
}

function tryParseAmount(text: string): number | undefined {
  const cleaned = removeDateFragments(text);
  const unitRe = /(¥|￥|\$|usd|rmb|cny)?\s*(-?\d+(?:\.\d+)?)\s*(元|块|rmb|cny|usd|dollar|刀)?/ig;
  let best: ScoreValue | undefined;
  let m: RegExpExecArray | null;
  while ((m = unitRe.exec(cleaned)) !== null) {
    const raw = m[2];
    const v = parseFloat(raw);
    if (Number.isNaN(v)) continue;
    let score = 1;
    if (m[1]) score += 2;
    if (m[3]) score += 2;
    if (Math.abs(v) >= 1) score += 1;
    if (!best || score > best.score) best = { value: v, score: score };
  }
  if (!best) {
    const nums = cleaned.match(/-?\d+(?:\.\d+)?/g);
    if (nums && nums.length > 0) {
      const v = parseFloat(nums[nums.length - 1]);
      if (!Number.isNaN(v)) best = { value: v, score: 1 };
    }
  }
  if (!best) {
    const cnMatch = cleaned.match(/[零一二两三四五六七八九十百千万]+\s*(元|块)?/);
    if (cnMatch) {
      const cnInt = parseChineseInteger(cnMatch[0].replace(/(元|块)/g, ''));
      if (typeof cnInt === 'number') best = { value: cnInt, score: 1 };
    }
  }
  if (!best) return undefined;
  const amt = best.value;
  if (!Number.isFinite(amt) || amt === 0) return undefined;
  return Math.abs(amt);
}

function tryParseDirection(text: string): BillingDirection | undefined {
  const t = text.toLowerCase();
  const inKw: string[] = ['收入', '发工资', '工资', '到账', '收款', '入账', '退款', '返现', '报销', 'salary', 'income', 'bonus', 'paid', 'received', 'refund', 'reimburse'];
  const outKw: string[] = ['支出', '花', '花了', '消费', '付款', '买', '买了', '交', '支付', '转出', '打车', '外卖', '租', 'rent', 'taxi', 'uber', 'spent', 'pay', 'paid for', 'purchase'];
  if (inKw.some(k => t.includes(k))) return BillingDirection.IN;
  if (outKw.some(k => t.includes(k))) return BillingDirection.OUT;
  return undefined;
}

function pickCategoryByKeywords(text: string, direction: BillingDirection | undefined): string | undefined {
  const t = text.toLowerCase();
  if (direction === BillingDirection.IN) {
    const incomeKeywords: string[] = ['工资', '发工资', 'salary', 'payday', 'pay check', 'paycheck'];
    if (incomeKeywords.some(k => t.includes(k))) return '工资';
    const financeKeywords: string[] = ['理财', '基金', '利息', '分红', 'interest', 'dividend', 'fund'];
    if (financeKeywords.some(k => t.includes(k))) return '理财';
    const giftKeywords: string[] = ['礼金', '红包', 'gift'];
    if (giftKeywords.some(k => t.includes(k))) return '礼金';
    const partKeywords: string[] = ['兼职', 'part time', 'freelance'];
    if (partKeywords.some(k => t.includes(k))) return '兼职';
    return undefined;
  }
  if (direction === BillingDirection.OUT) {
    const foodKeywords: string[] = ['饭', '吃', '餐', '午饭', '晚饭', '早餐', '夜宵', '外卖', '奶茶', '咖啡', 'food', 'lunch', 'dinner', 'breakfast', 'takeaway'];
    if (foodKeywords.some(k => t.includes(k))) return '餐饮';
    const transportKeywords: string[] = ['打车', '地铁', '公交', '高铁', '火车', '机票', '滴滴', 'uber', 'taxi', 'metro', 'bus', 'train', 'flight'];
    if (transportKeywords.some(k => t.includes(k))) return '交通';
    const shoppingKeywords: string[] = ['买', '购物', 'shop', 'shopping', '淘宝', '京东'];
    if (shoppingKeywords.some(k => t.includes(k))) return '购物';
    const housingKeywords: string[] = ['房租', '租房', '水电', '物业', 'rent', 'electric', 'water'];
    if (housingKeywords.some(k => t.includes(k))) return '住房';
    const medicalKeywords: string[] = ['药', '医院', '挂号', 'medical', 'hospital', 'doctor'];
    if (medicalKeywords.some(k => t.includes(k))) return '医疗';
    const alcoholKeywords: string[] = ['烟', '酒', 'wine', 'beer', 'cigarette'];
    if (alcoholKeywords.some(k => t.includes(k))) return '烟酒';
    const snackKeywords: string[] = ['零食', 'snack'];
    if (snackKeywords.some(k => t.includes(k))) return '零食';
    const travelKeywords: string[] = ['旅行', '旅游', 'hotel', 'trip', 'travel'];
    if (travelKeywords.some(k => t.includes(k))) return '旅行';
    const petKeywords: string[] = ['宠物', 'pet', 'cat', 'dog'];
    if (petKeywords.some(k => t.includes(k))) return '宠物';
    const clothingKeywords: string[] = ['衣', '服装', '鞋', 'coat', 'clothes'];
    if (clothingKeywords.some(k => t.includes(k))) return '服装';
    const digitalKeywords: string[] = ['数码', '手机', '电脑', 'digital', 'phone', 'laptop'];
    if (digitalKeywords.some(k => t.includes(k))) return '数码';
    const donateKeywords: string[] = ['捐', '捐赠', 'donate', 'donation'];
    if (donateKeywords.some(k => t.includes(k))) return '捐赠';
    const giftOutKeywords: string[] = ['礼物', 'gift'];
    if (giftOutKeywords.some(k => t.includes(k))) return '礼物';
    return undefined;
  }
  if (['发工资', '工资', 'salary', 'income', 'received'].some(k => t.includes(k))) return '工资';
  if (['打车', '地铁', 'uber', 'taxi', 'metro', 'bus'].some(k => t.includes(k))) return '交通';
  if (['午饭', '晚饭', '早餐', '外卖', 'food', 'lunch', 'dinner'].some(k => t.includes(k))) return '餐饮';
  return undefined;
}

function ruleParse(text: string, now: Date): RuleParsed {
  const amount = tryParseAmount(text);
  const direction = tryParseDirection(text);
  const date = tryParseExplicitDate(text, now) ?? tryParseRelativeDate(text, now);
  const categoryName = pickCategoryByKeywords(text, direction);

  let confidence = 0;
  if (amount) confidence += 0.4;
  if (direction !== undefined) confidence += 0.2;
  if (categoryName) confidence += 0.2;
  if (date) confidence += 0.1;
  confidence += 0.1;

  return {
    amount: amount,
    direction: direction,
    categoryName: categoryName,
    date: date,
    remark: text,
    confidence: confidence
  };
}

function extractFirstJsonObject(text: string): string | undefined {
  const s = (text ?? '').trim();
  if (!s) return undefined;
  const unfenced = s.replace(/```(?:json)?/gi, '').replace(/```/g, '').trim();
  const start = unfenced.indexOf('{');
  const end = unfenced.lastIndexOf('}');
  if (start < 0 || end <= start) return undefined;
  return unfenced.slice(start, end + 1);
}

async function llmParse(text: string, now: Date, expenseCats: string[], incomeCats: string[], config: AiBillingConfig): Promise<LlmParsed | undefined> {
  if (!config.baseUrl || !config.apiKey) return undefined;

  const today = ymd(now);
  const system = '你是一个记账助手。把用户输入的一句话解析为严格 JSON。' +
    '只输出 JSON，不要输出解释、不要 markdown。' +
    '字段要求：amount(number|null), direction("IN"|"OUT"|null), category(string|null), date("YYYY-MM-DD"|null), remark(string|null), needMoreInfo(boolean), missingFields(string[]), friendlyTip(string|null)。' +
    'category 必须从给定候选列表中选择最贴近的一项：支出=' +
    JSON.stringify(expenseCats) +
    '；收入=' +
    JSON.stringify(incomeCats) +
    '。' +
    `今天日期是 ${today}。如果用户未提及日期则 date 设为 ${today}。` +
    '如果无法确定 amount 或 direction 或 category，请设置 needMoreInfo=true，并在 missingFields 给出缺失字段，同时 friendlyTip 用中文给出补充示例。';

  const messages: ChatMessage[] = [
    { role: 'system', content: system },
    { role: 'user', content: text }
  ];

  const body: RequestBody = {
    model: config.model,
    temperature: 0.2,
    messages: messages
  };

  const headers: Record<string, string> = {};
  if (config.apiKeyHeader.toLowerCase() === 'authorization') {
    headers[config.apiKeyHeader] = `${config.apiKeyPrefix}${config.apiKey}`;
  } else {
    headers[config.apiKeyHeader] = config.apiKey;
  }

  try {
    const resp = await postJson(config.baseUrl, headers, body, config.timeoutMs);
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      return undefined;
    }
    const json = JSON.parse(resp.bodyText) as OpenAiResponse;
    const content = json?.choices?.[0]?.message?.content ?? '';
    const objText = extractFirstJsonObject(content);
    if (!objText) return undefined;
    return JSON.parse(objText) as LlmParsed;
  } catch (_e) {
    return undefined;
  }
}

function resolveBillType(direction: BillingDirection, categoryName: string, expenseTypes: BillTypeOption[], incomeTypes: BillTypeOption[]): BillingType | undefined {
  const list = direction === BillingDirection.OUT ? expenseTypes : incomeTypes;
  for (let i = 0; i < list.length; i++) {
    if (list[i].title === categoryName) {
      return { icon: list[i].img, name: list[i].title };
    }
  }
  return undefined;
}

function buildTimestamp(date: Date, now: Date): number {
  const ts = new Date(date.getTime());
  ts.setHours(now.getHours(), now.getMinutes(), now.getSeconds(), now.getMilliseconds());
  return ts.getTime();
}

function merge(rule: RuleParsed, llm: LlmParsed | undefined, now: Date): MergedRuleParsed {
  if (!llm) {
    return {
      amount: rule.amount,
      direction: rule.direction,
      categoryName: rule.categoryName,
      date: rule.date,
      remark: rule.remark,
      confidence: rule.confidence,
      used: 'rule'
    };
  }

  let mergedAmount = rule.amount;
  if (typeof llm.amount === 'number' && llm.amount > 0) mergedAmount = llm.amount;

  let mergedDirection = rule.direction;
  if (llm.direction === 'IN') mergedDirection = BillingDirection.IN;
  if (llm.direction === 'OUT') mergedDirection = BillingDirection.OUT;

  let mergedCategory = rule.categoryName;
  if (typeof llm.category === 'string' && llm.category.trim()) mergedCategory = llm.category.trim();

  let mergedDate = rule.date;
  if (typeof llm.date === 'string') {
    const d = parseYmd(llm.date.trim(), now);
    if (d) mergedDate = d;
  }

  let mergedRemark = rule.remark;
  if (typeof llm.remark === 'string' && llm.remark.trim()) mergedRemark = llm.remark.trim();

  const mergedConfidence = Math.max(rule.confidence, 0.7);

  return {
    amount: mergedAmount,
    direction: mergedDirection,
    categoryName: mergedCategory,
    date: mergedDate,
    remark: mergedRemark,
    confidence: mergedConfidence,
    used: 'hybrid'
  };
}

function toMissing(parsed: RuleParsed): MissingField[] {
  const missing: MissingField[] = [];
  if (typeof parsed.amount !== 'number') missing.push('amount');
  if (parsed.direction === undefined) missing.push('direction');
  if (!parsed.categoryName) missing.push('category');
  return missing;
}

export class AiBillingParser {
  public static async parseToBill(text: string, options: AiParseOptions): Promise<AiParseResult> {
    const now = options.now ?? new Date();
    const normalized = normalizeText(text);
    if (!normalized) {
      return {
        ok: false,
        tip: '请输入一句话，例如：今天午饭25 / 发工资5000 / 昨晚打车32',
        missing: ['amount'],
        used: 'rule'
      };
    }

    const expenseCats = options.expenseTypes.map(t => t.title);
    const incomeCats = options.incomeTypes.map(t => t.title);

    const rule = ruleParse(normalized, now);

    const config: AiBillingConfig = {
      baseUrl: options.config?.baseUrl ?? TEXT_AI_CONFIG.baseUrl,
      apiKey: options.config?.apiKey ?? TEXT_AI_CONFIG.apiKey,
      model: options.config?.model ?? TEXT_AI_CONFIG.model,
      apiKeyHeader: options.config?.apiKeyHeader ?? TEXT_AI_CONFIG.apiKeyHeader,
      apiKeyPrefix: options.config?.apiKeyPrefix ?? TEXT_AI_CONFIG.apiKeyPrefix,
      timeoutMs: options.config?.timeoutMs ?? TEXT_AI_CONFIG.timeoutMs
    };

    let llm: LlmParsed | undefined;
    const shouldTryLlm = options.preferLLM === true || rule.confidence < 0.8;
    if (shouldTryLlm) {
      llm = await llmParse(normalized, now, expenseCats, incomeCats, config);
    }

    const merged = merge(rule, llm, now);

    let finalDirection = merged.direction;
    if (finalDirection === undefined && merged.categoryName) {
      if (incomeCats.includes(merged.categoryName)) finalDirection = BillingDirection.IN;
      if (expenseCats.includes(merged.categoryName)) finalDirection = BillingDirection.OUT;
    }

    const missing = toMissing({
      amount: merged.amount,
      direction: finalDirection,
      categoryName: merged.categoryName,
      confidence: merged.confidence,
      date: merged.date,
      remark: merged.remark
    });

    if (missing.length > 0) {
      const tipParts: string[] = [];
      if (missing.includes('amount')) tipParts.push('金额');
      if (missing.includes('direction')) tipParts.push('收支类型（收入/支出）');
      if (missing.includes('category')) tipParts.push('分类（如 餐饮/交通/工资）');

      let tip: string;
      if (llm?.friendlyTip && llm.friendlyTip.trim()) {
        tip = llm.friendlyTip.trim();
      } else {
        tip = `我还需要补充：${tipParts.join('、')}。例如：今天午饭 25（餐饮支出）`;
      }

      return {
        ok: false,
        tip: tip,
        missing: missing,
        used: merged.used
      };
    }

    const direction = finalDirection as BillingDirection;
    const categoryName = merged.categoryName as string;

    const resolvedType = resolveBillType(direction, categoryName, options.expenseTypes, options.incomeTypes);
    if (!resolvedType) {
      return {
        ok: false,
        tip: `分类"${categoryName}"不在当前分类列表中，请手动选择一个分类。`,
        missing: ['category'],
        used: merged.used
      };
    }

    const date = merged.date ?? new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const timestamp = buildTimestamp(date, now);
    const amount = merged.amount as number;
    const remark = (merged.remark ?? normalized).trim();

    const bill: BillingInfo = {
      type: resolvedType,
      amount: amount,
      direction: direction,
      timestamp: timestamp,
      remark: remark
    };

    const summary = `${direction === BillingDirection.IN ? '收入' : '支出'} / ${categoryName} / ${amount.toFixed(2)} / ${ymd(date)}`;
    const usedFinal = (merged.used === 'rule' && llm !== undefined) ? 'hybrid' : merged.used;
    return {
      ok: true,
      bill: bill,
      used: usedFinal,
      summary: summary
    };
  }
}
