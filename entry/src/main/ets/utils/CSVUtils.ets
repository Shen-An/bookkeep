// Copyright (c) 2023 Ericple
// 风风记账 is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
// http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT, MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.
import { BillingDirection, BillingInfo, BillingType, Logger } from '@ohos/common';
import { defaultExpenseType, defaultIncomeType } from '../data/balanceTypes';
import { fileIo } from '@kit.CoreFileKit';
import { util } from '@kit.ArkTS';
import zip from "@ohos.zlib"

let TAG = "CSVUtils";

/**
 * 导入结果
 */
export interface ImportResult {
  success: boolean;
  message: string;
  importedCount: number;
  items: BillingInfo[];
}

/**
 * CSV 工具类 - 支持标准账单 CSV、微信账单 CSV/XLSX 格式的导入导出
 */
export class CSVUtils {
  /**
   * 导出账单为 CSV 字符串
   * @param items 账单列表
   * @returns CSV 格式的字符串
   */
  public static exportToCSV(items: BillingInfo[]): string {
    // CSV 头部说明
    let csv = "\uFEFF"; // BOM for UTF-8
    csv += "风风记账 账单导出\n";
    csv += "导出时间: " + CSVUtils.formatDate(new Date()) + "\n";
    csv += "共" + items.length + "笔记录\n";
    csv += "----------------------账单明细列表--------------------\n";

    // CSV 列头
    const headers = [
      "交易时间",   // 交易时间
      "交易类型",   // 交易类型
      "交易对方",   // 交易对方
      "商品",       // 商品
      "收/支",      // 收/支
      "金额(元)",   // 金额(元)
      "备注"        // 备注
    ];
    csv += headers.join(",") + "\n";

    // 数据行
    for (const item of items) {
      const time = CSVUtils.formatDate(new Date(item.timestamp));
      const type = item.type.name;
      const counterparty = CSVUtils.escapeCSV(item.remark || "");
      const direction = item.direction === BillingDirection.IN ? "收入" : "支出";
      const amount = item.amount.toFixed(2);
      const remark = "";

      const row = [time, type, counterparty, "", direction, amount, remark];
      csv += row.join(",") + "\n";
    }

    return csv;
  }

  /**
   * 从标准 CSV 导入账单
   * @param csvText CSV 文本内容
   * @returns 导入结果
   */
  public static importFromCSV(csvText: string): ImportResult {
    try {
      const lines = csvText.split('\n');
      const items: BillingInfo[] = [];
      let dataStartIndex = -1;

      // 找到数据起始行（跳过头部信息）
      for (let i = 0; i < lines.length; i++) {
        const line = lines[i].trim();
        // 跳过空行和 BOM
        if (line === "" || line === "\uFEFF") continue;
        // 找到列头行（包含 交易时间 等字段）
        if (line.indexOf("交易时间") !== -1 &&
            line.indexOf("收/支") !== -1) {
          dataStartIndex = i + 1;
          break;
        }
      }

      if (dataStartIndex === -1) {
        return {
          success: false,
          message: "无法识别文件格式，请检查文件内容",
          importedCount: 0,
          items: []
        };
      }

      // 解析数据行
      for (let i = dataStartIndex; i < lines.length; i++) {
        const line = lines[i].trim();
        if (line === "") continue;

        const fields = CSVUtils.parseCSVLine(line);
        if (fields.length < 6) continue;

        const info = CSVUtils.parseStandardRow(fields);
        if (info) {
          items.push(info);
        }
      }

      return {
        success: true,
        message: "成功导入 " + items.length + " 条记录",
        importedCount: items.length,
        items: items
      };
    } catch (e) {
      Logger.err(TAG, "import CSV error: " + (e as Error).message);
      return {
        success: false,
        message: "解析错误: " + (e as Error).message,
        importedCount: 0,
        items: []
      };
    }
  }

  /**
   * 导入微信账单格式（CSV）
   * 微信账单格式:
   * 交易时间,交易类型,交易对方,商品,收/支,金额(元),支付方式,当前状态,交易单号,商户单号,备注
   * @param csvText 微信导出的 CSV 文本
   * @returns 导入结果
   */
  public static importWeChatBill(csvText: string): ImportResult {
    try {
      const lines = csvText.split('\n');
      const items: BillingInfo[] = [];
      let dataStartIndex = -1;

      // 解析微信账单头部信息
      for (let i = 0; i < lines.length; i++) {
        const line = lines[i].trim();
        if (line === "" || line === "\uFEFF") continue;

        // 找到列头行
        if (line.indexOf("交易时间") !== -1 &&
            line.indexOf("交易类型") !== -1 &&
            line.indexOf("收/支") !== -1) {
          dataStartIndex = i + 1;
          break;
        }
      }

      if (dataStartIndex === -1) {
        return {
          success: false,
          message: "无法识别微信账单格式，请检查文件内容",
          importedCount: 0,
          items: []
        };
      }

      // 解析数据行
      for (let i = dataStartIndex; i < lines.length; i++) {
        const line = lines[i].trim();
        if (line === "") continue;

        // 检查是否遇到分隔线或尾部注释
        if (line.indexOf("---") !== -1 || line.indexOf("注：") !== -1) {
          break;
        }

        const fields = CSVUtils.parseCSVLine(line);
        // 微信账单有11列: 交易时间,交易类型,交易对方,商品,收/支,金额(元),支付方式,当前状态,交易单号,商户单号,备注
        if (fields.length < 6) continue;

        const info = CSVUtils.parseWeChatRow(fields);
        if (info) {
          items.push(info);
        }
      }

      return {
        success: true,
        message: "成功导入 " + items.length + " 条微信账单记录",
        importedCount: items.length,
        items: items
      };
    } catch (e) {
      Logger.err(TAG, "import WeChat bill error: " + (e as Error).message);
      return {
        success: false,
        message: "解析错误: " + (e as Error).message,
        importedCount: 0,
        items: []
      };
    }
  }

  /**
   * 导入 XLSX 格式的微信账单
   * 微信导出的账单为 .xlsx 格式（ZIP 压缩的 XML）
   * @param filePath xlsx 文件路径
   * @param context 应用上下文，用于临时目录
   * @returns 导入结果
   */
  public static async importWeChatXLSX(filePath: string, context: Context): Promise<ImportResult> {
    try {
      // 1. 创建临时解压目录
      const tempDir = context.tempDir + "/xlsx_temp_" + new Date().getTime();
      try {
        fileIo.mkdirSync(tempDir);
      } catch (e) {
        // 目录可能已存在
      }

      // 2. 解压 xlsx 文件到临时目录
      try {
        await zip.decompressFile(filePath, tempDir);
      } catch (zipErr) {
        Logger.err(TAG, "decompress xlsx failed: " + (zipErr as Error).message);
        return {
          success: false,
          message: "无法解压 Excel 文件，请确认文件格式正确",
          importedCount: 0,
          items: []
        };
      }

      // 3. 读取 shared strings
      const sharedStrings = await CSVUtils.parseSharedStrings(tempDir);

      // 4. 读取 sheet 数据
      const rows = await CSVUtils.parseSheetData(tempDir, sharedStrings);

      // 5. 清理临时目录
      try {
        fileIo.rmdirSync(tempDir);
      } catch (e) {
        Logger.err(TAG, "cleanup temp dir failed: " + (e as Error).message);
      }

      // 6. 解析数据行（跳过头部信息行）
      const items: BillingInfo[] = [];
      let dataStartIndex = -1;

      // 找到列头行（包含"交易时间"的行）
      for (let i = 0; i < rows.length; i++) {
        if (rows[i].length > 0 && rows[i][0].indexOf("交易时间") !== -1) {
          dataStartIndex = i + 1;
          break;
        }
      }

      if (dataStartIndex === -1) {
        return {
          success: false,
          message: "无法识别微信账单格式，请检查文件内容",
          importedCount: 0,
          items: []
        };
      }

      // 解析数据行
      for (let i = dataStartIndex; i < rows.length; i++) {
        const fields = rows[i];
        if (fields.length < 6) continue;

        // 检查是否遇到分隔线或尾部注释
        const firstField = fields[0].trim();
        if (firstField.indexOf("---") !== -1 || firstField.indexOf("注：") !== -1) {
          break;
        }

        const info = CSVUtils.parseWeChatRow(fields);
        if (info) {
          items.push(info);
        }
      }

      return {
        success: true,
        message: "成功导入 " + items.length + " 条微信账单记录",
        importedCount: items.length,
        items: items
      };
    } catch (e) {
      Logger.err(TAG, "import WeChat XLSX error: " + (e as Error).message);
      return {
        success: false,
        message: "解析错误: " + (e as Error).message,
        importedCount: 0,
        items: []
      };
    }
  }

  /**
   * 解析 XLSX 中的共享字符串表
   */
  private static async parseSharedStrings(tempDir: string): Promise<string[]> {
    const strings: string[] = [];
    const ssPath = tempDir + "/xl/sharedStrings.xml";

    try {
      let file = fileIo.openSync(ssPath, fileIo.OpenMode.READ_ONLY);
      let stat = fileIo.statSync(ssPath);
      let buf = new ArrayBuffer(stat.size);
      fileIo.readSync(file.fd, buf);
      fileIo.closeSync(file);

      let uint8Arr = new Uint8Array(buf);
      let textDecoder = new util.TextDecoder("utf-8", { ignoreBOM: true });
      let content = textDecoder.decodeToString(uint8Arr);

      // 解析 shared strings XML
      // 支持简单格式: <sst><si><t>text</t></si></sst>
      // 支持富文本格式: <sst><si><r><t>part1</t></r><r><t>part2</t></r></si></sst>
      let inSi = false;
      let inT = false;
      let currentText = "";
      let tagName = "";

      for (let i = 0; i < content.length; i++) {
        const ch = content[i];
        if (ch === '<') {
          // 开始标签
          tagName = "";
          i++;
          let isEndTag = false;
          if (i < content.length && content[i] === '/') {
            isEndTag = true;
            i++;
          }
          while (i < content.length && content[i] !== '>' && content[i] !== ' ' && content[i] !== '/') {
            tagName += content[i];
            i++;
          }
          // 跳过属性
          while (i < content.length && content[i] !== '>') {
            i++;
          }

          if (tagName === "si" && !isEndTag) {
            inSi = true;
            currentText = "";
          } else if (tagName === "si" && isEndTag) {
            inSi = false;
            // 解码 XML 实体
            strings.push(CSVUtils.decodeXMLEntities(currentText));
            currentText = "";
          } else if (tagName === "t" && !isEndTag) {
            inT = true;
            // 注意: 不重置 currentText，以支持富文本中多个 <t> 的拼接
          } else if (tagName === "t" && isEndTag) {
            inT = false;
          }
        } else if (inT) {
          currentText += ch;
        }
      }
    } catch (e) {
      Logger.err(TAG, "parse shared strings error: " + (e as Error).message);
    }

    return strings;
  }

  /**
   * 解析 XLSX 中的工作表数据
   */
  private static async parseSheetData(tempDir: string, sharedStrings: string[]): Promise<string[][]> {
    const allRows: string[][] = [];
    const sheetPath = tempDir + "/xl/worksheets/sheet1.xml";

    try {
      let file = fileIo.openSync(sheetPath, fileIo.OpenMode.READ_ONLY);
      let stat = fileIo.statSync(sheetPath);
      let buf = new ArrayBuffer(stat.size);
      fileIo.readSync(file.fd, buf);
      fileIo.closeSync(file);

      let uint8Arr = new Uint8Array(buf);
      let textDecoder = new util.TextDecoder("utf-8", { ignoreBOM: true });
      let content = textDecoder.decodeToString(uint8Arr);

      // 解析 sheet XML
      // 格式: <worksheet><sheetData><row r="1"><c r="A1" t="s"><v>0</v></c>...</row></sheetData></worksheet>
      let inRow = false;
      let inCell = false;
      let inValue = false;
      let inInlineStr = false;
      let inInlineT = false;
      let currentRow: string[] = [];
      let currentValue = "";
      let currentInlineStr = "";
      let currentCellRef = "";
      let currentCellType = "";
      let tagName = "";
      let rowIndex = "";

      for (let i = 0; i < content.length; i++) {
        const ch = content[i];
        if (ch === '<') {
          tagName = "";
          i++;
          let isEndTag = false;
          let isSelfClose = false;
          if (i < content.length && content[i] === '/') {
            isEndTag = true;
            i++;
          }
          while (i < content.length && content[i] !== '>' && content[i] !== ' ' && content[i] !== '/') {
            tagName += content[i];
            i++;
          }
          // 检查自闭合
          if (i < content.length && content[i] === '/') {
            isSelfClose = true;
            i++;
          }
          // 解析属性
          let attrNames: string[] = [];
          let attrValues: string[] = [];
          while (i < content.length && content[i] !== '>') {
            // 跳过空格
            while (i < content.length && content[i] === ' ') i++;
            if (i >= content.length || content[i] === '>') break;
            let attrName = "";
            let attrValue = "";
            while (i < content.length && content[i] !== '=' && content[i] !== '>' && content[i] !== ' ') {
              attrName += content[i];
              i++;
            }
            if (i < content.length && content[i] === '=') {
              i++;
              if (i < content.length && (content[i] === '"' || content[i] === "'")) {
                const quote = content[i];
                i++;
                while (i < content.length && content[i] !== quote) {
                  attrValue += content[i];
                  i++;
                }
                i++; // skip closing quote
              }
            }
            if (attrName) {
              attrNames.push(attrName);
              attrValues.push(attrValue);
            }
          }
          // skip '>'
          if (i < content.length && content[i] === '>') {
            // continue
          }

          if (tagName === "row" && !isEndTag) {
            inRow = true;
            currentRow = [];
            rowIndex = CSVUtils.getAttr(attrNames, attrValues, "r");
          } else if (tagName === "row" && isEndTag) {
            inRow = false;
            if (currentRow.length > 0) {
              allRows.push(currentRow);
            }
            currentRow = [];
          } else if (tagName === "c" && !isEndTag) {
            inCell = true;
            currentCellRef = CSVUtils.getAttr(attrNames, attrValues, "r");
            currentCellType = CSVUtils.getAttr(attrNames, attrValues, "t");
            currentValue = "";
            currentInlineStr = "";
          } else if (tagName === "c" && isEndTag) {
            inCell = false;
            // 解析单元格值
            let cellValue = currentValue;
            if (currentCellType === "s" && currentValue !== "") {
              const idx = parseInt(currentValue);
              if (!isNaN(idx) && idx >= 0 && idx < sharedStrings.length) {
                cellValue = sharedStrings[idx];
              }
            } else if (currentCellType === "inlineStr" && currentInlineStr !== "") {
              cellValue = CSVUtils.decodeXMLEntities(currentInlineStr);
            }
            currentRow.push(cellValue);
          } else if (tagName === "v" && !isEndTag) {
            inValue = true;
            currentValue = "";
          } else if (tagName === "v" && isEndTag) {
            inValue = false;
          } else if (tagName === "is" && !isEndTag) {
            inInlineStr = true;
          } else if (tagName === "is" && isEndTag) {
            inInlineStr = false;
          } else if (tagName === "t" && !isEndTag && inInlineStr) {
            inInlineT = true;
          } else if (tagName === "t" && isEndTag && inInlineStr) {
            inInlineT = false;
          }
        } else if (inValue) {
          currentValue += ch;
        } else if (inInlineT) {
          currentInlineStr += ch;
        }
      }
    } catch (e) {
      Logger.err(TAG, "parse sheet data error: " + (e as Error).message);
    }

    return allRows;
  }

  /**
   * 解析 CSV 行（处理引号转义）
   */
  private static parseCSVLine(line: string): string[] {
    const fields: string[] = [];
    let current = "";
    let inQuotes = false;

    for (let i = 0; i < line.length; i++) {
      const char = line[i];
      if (char === '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] === '"') {
          current += '"';
          i++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if (char === ',' && !inQuotes) {
        fields.push(current.trim());
        current = "";
      } else {
        current += char;
      }
    }
    fields.push(current.trim());

    return fields;
  }

  /**
   * 解析标准账单行
   * 格式: 交易时间,交易类型,交易对方,商品,收/支,金额(元),备注
   */
  private static parseStandardRow(fields: string[]): BillingInfo | null {
    try {
      const timeStr = fields[0].trim();
      const typeStr = fields[1].trim();
      const counterparty = fields[2].trim();
      const directionStr = fields[4].trim();
      let amountStr = fields[5].trim().replace(/^¥/, "").replace(/^￥/, "");

      if (!timeStr || !amountStr) return null;

      const timestamp = new Date(timeStr).getTime();
      if (isNaN(timestamp)) return null;

      const amount = parseFloat(amountStr);
      if (isNaN(amount)) return null;

      const direction = directionStr === "收入" ? BillingDirection.IN : BillingDirection.OUT;
      const billType = CSVUtils.getBillingTypeByName(typeStr);
      const remark = counterparty !== "" ? counterparty : "";

      return {
        timestamp: timestamp,
        type: billType,
        amount: amount,
        direction: direction,
        remark: remark
      };
    } catch (e) {
      return null;
    }
  }

  /**
   * 解析微信账单行
   * 微信格式: 交易时间,交易类型,交易对方,商品,收/支,金额(元),支付方式,当前状态,交易单号,商户单号,备注
   */
  private static parseWeChatRow(fields: string[]): BillingInfo | null {
    try {
      const timeStr = fields[0].trim();
      const typeStr = fields[1].trim();
      const counterparty = fields[2].trim();
      const goods = fields[3].trim();
      const directionStr = fields[4].trim();
      let amountStr = fields[5].trim();
      // 微信金额格式为 ¥0.50，去掉货币符号
      amountStr = amountStr.replace(/^¥/, "").replace(/^￥/, "");

      if (!timeStr || !amountStr) return null;

      const timestamp = new Date(timeStr).getTime();
      if (isNaN(timestamp)) return null;

      const amount = parseFloat(amountStr);
      if (isNaN(amount)) return null;

      const direction = directionStr === "收入" ? BillingDirection.IN : BillingDirection.OUT;
      // 使用交易对方+商品描述进行智能分类
      const billType = CSVUtils.getWeChatType(typeStr, counterparty, goods, direction);

      // 构建备注：优先使用交易对方，其次商品描述
      let remark = counterparty;
      if (remark === "" || remark === "/") {
        remark = goods !== "/" ? goods : "";
      }

      return {
        timestamp: timestamp,
        type: billType,
        amount: amount,
        direction: direction,
        remark: remark
      };
    } catch (e) {
      return null;
    }
  }

  /**
   * 根据类型名称获取对应的 BillingType
   */
  private static getBillingTypeByName(typeName: string): BillingType {
    // 先在支出类型中查找
    for (const t of defaultExpenseType) {
      if (t.title === typeName) {
        return { icon: t.img, name: t.title };
      }
    }
    // 再在收入类型中查找
    for (const t of defaultIncomeType) {
      if (t.title === typeName) {
        return { icon: t.img, name: t.title };
      }
    }
    // 默认返回"其他"
    return { icon: $r("app.media.otherIcon"), name: "其他" };
  }

  /**
   * 根据微信交易类型 + 交易对方 + 商品描述 智能获取 BillingType
   * @param typeStr 微信交易类型（转账/二维码收款/其他等）
   * @param counterparty 交易对方
   * @param goods 商品描述
   * @param direction 收支方向
   */
  private static getWeChatType(typeStr: string, counterparty: string = "", goods: string = "", direction: BillingDirection = BillingDirection.OUT): BillingType {
    // 1. 先按交易类型映射
    if (typeStr === "美食") {
      return { icon: $r("app.media.eatIcon"), name: "餐饮" };
    }
    if (typeStr === "交通") {
      return { icon: $r("app.media.metroExpenseIcon"), name: "交通" };
    }
    if (typeStr === "购物") {
      return { icon: $r("app.media.shoppingIcon"), name: "购物" };
    }

    // 2. 根据交易对方/商品描述进行智能分类
    const keywords = counterparty + " " + goods;

    // 收入类关键词匹配
    if (direction === BillingDirection.IN) {
      if (keywords.indexOf("工资") !== -1 || keywords.indexOf("薪资") !== -1 || keywords.indexOf("薪酬") !== -1) {
        return { icon: $r("app.media.salaryIcon"), name: "工资" };
      }
      if (keywords.indexOf("理财") !== -1 || keywords.indexOf("基金") !== -1 || keywords.indexOf("利息") !== -1) {
        return { icon: $r("app.media.foundationIcon"), name: "理财" };
      }
      if (keywords.indexOf("兼职") !== -1 || keywords.indexOf("劳务") !== -1 || keywords.indexOf("稿费") !== -1) {
        return { icon: $r("app.media.partTimeIncomeIcon"), name: "兼职" };
      }
      if (keywords.indexOf("红包") !== -1 || keywords.indexOf("礼金") !== -1 || keywords.indexOf("转账") !== -1) {
        return { icon: $r("app.media.giftMoneyIcon"), name: "礼金" };
      }
      // 默认收入归为"其它"
      return { icon: $r("app.media.otherIcon"), name: "其它" };
    }

    // 支出类关键词匹配
    if (keywords.indexOf("餐饮") !== -1 || keywords.indexOf("美食") !== -1 || keywords.indexOf("外卖") !== -1 ||
        keywords.indexOf("吃饭") !== -1 || keywords.indexOf("餐厅") !== -1 || keywords.indexOf("食堂") !== -1 ||
        keywords.indexOf("早餐") !== -1 || keywords.indexOf("午餐") !== -1 || keywords.indexOf("晚餐") !== -1) {
      return { icon: $r("app.media.eatIcon"), name: "餐饮" };
    }
    if (keywords.indexOf("购物") !== -1 || keywords.indexOf("超市") !== -1 || keywords.indexOf("商场") !== -1 ||
        keywords.indexOf("淘宝") !== -1 || keywords.indexOf("京东") !== -1 || keywords.indexOf("拼多多") !== -1 ||
        keywords.indexOf("便利店") !== -1 || keywords.indexOf("商店") !== -1) {
      return { icon: $r("app.media.shoppingIcon"), name: "购物" };
    }
    if (keywords.indexOf("蔬菜") !== -1 || keywords.indexOf("水果") !== -1 || keywords.indexOf("菜市场") !== -1 ||
        keywords.indexOf("生鲜") !== -1 || keywords.indexOf("买菜") !== -1) {
      return { icon: $r("app.media.vegetablesExpenseIcon"), name: "蔬菜" };
    }
    if (keywords.indexOf("日用") !== -1 || keywords.indexOf("家居") !== -1 || keywords.indexOf("家用品") !== -1 ||
        keywords.indexOf("生活用品") !== -1) {
      return { icon: $r("app.media.dailyExpenseIcon"), name: "日用" };
    }
    if (keywords.indexOf("交通") !== -1 || keywords.indexOf("地铁") !== -1 || keywords.indexOf("公交") !== -1 ||
        keywords.indexOf("打车") !== -1 || keywords.indexOf("滴滴") !== -1 || keywords.indexOf("出租车") !== -1 ||
        keywords.indexOf("加油") !== -1 || keywords.indexOf("停车") !== -1) {
      return { icon: $r("app.media.metroExpenseIcon"), name: "交通" };
    }
    if (keywords.indexOf("旅行") !== -1 || keywords.indexOf("旅游") !== -1 || keywords.indexOf("酒店") !== -1 ||
        keywords.indexOf("机票") !== -1 || keywords.indexOf("火车票") !== -1 || keywords.indexOf("景点") !== -1) {
      return { icon: $r("app.media.travelExpenseIcon"), name: "旅行" };
    }
    if (keywords.indexOf("宠物") !== -1 || keywords.indexOf("猫") !== -1 || keywords.indexOf("狗") !== -1 ||
        keywords.indexOf("兽医") !== -1 || keywords.indexOf("宠物店") !== -1) {
      return { icon: $r("app.media.petExpenseIcon"), name: "宠物" };
    }
    if (keywords.indexOf("知识") !== -1 || keywords.indexOf("课程") !== -1 || keywords.indexOf("培训") !== -1 ||
        keywords.indexOf("教育") !== -1 || keywords.indexOf("学习") !== -1 || keywords.indexOf("书") !== -1 ||
        keywords.indexOf("图书") !== -1 || keywords.indexOf("付费") !== -1) {
      return { icon: $r("app.media.knowledgeExpenseIcon"), name: "知识" };
    }
    if (keywords.indexOf("服装") !== -1 || keywords.indexOf("衣服") !== -1 || keywords.indexOf("鞋") !== -1 ||
        keywords.indexOf("包") !== -1 || keywords.indexOf("服饰") !== -1 || keywords.indexOf("穿搭") !== -1) {
      return { icon: $r("app.media.clothExpenseIcon"), name: "服装" };
    }
    if (keywords.indexOf("数码") !== -1 || keywords.indexOf("手机") !== -1 || keywords.indexOf("电脑") !== -1 ||
        keywords.indexOf("电子") !== -1 || keywords.indexOf("配件") !== -1) {
      return { icon: $r("app.media.digitalProductExpenseIcon"), name: "数码" };
    }
    if (keywords.indexOf("烟酒") !== -1 || keywords.indexOf("香烟") !== -1 || keywords.indexOf("酒") !== -1 ||
        keywords.indexOf("白酒") !== -1 || keywords.indexOf("啤酒") !== -1) {
      return { icon: $r("app.media.wineExpenseIcon"), name: "烟酒" };
    }
    if (keywords.indexOf("零食") !== -1 || keywords.indexOf("小吃") !== -1 || keywords.indexOf("奶茶") !== -1 ||
        keywords.indexOf("饮料") !== -1 || keywords.indexOf("甜品") !== -1 || keywords.indexOf("蛋糕") !== -1) {
      return { icon: $r("app.media.snacksExpenseIcon"), name: "零食" };
    }
    if (keywords.indexOf("医疗") !== -1 || keywords.indexOf("医院") !== -1 || keywords.indexOf("药") !== -1 ||
        keywords.indexOf("看病") !== -1 || keywords.indexOf("体检") !== -1 || keywords.indexOf("医保") !== -1) {
      return { icon: $r("app.media.medicalExpenseIcon"), name: "医疗" };
    }
    if (keywords.indexOf("住房") !== -1 || keywords.indexOf("房租") !== -1 || keywords.indexOf("物业") !== -1 ||
        keywords.indexOf("水电") !== -1 || keywords.indexOf("燃气") !== -1 || keywords.indexOf("装修") !== -1) {
      return { icon: $r("app.media.houseExpenseIcon"), name: "住房" };
    }
    if (keywords.indexOf("儿童") !== -1 || keywords.indexOf("母婴") !== -1 || keywords.indexOf("玩具") !== -1 ||
        keywords.indexOf("奶粉") !== -1 || keywords.indexOf("尿不湿") !== -1) {
      return { icon: $r("app.media.childExpenseIcon"), name: "儿童" };
    }
    if (keywords.indexOf("汽车") !== -1 || keywords.indexOf("洗车") !== -1 || keywords.indexOf("保养") !== -1 ||
        keywords.indexOf("维修") !== -1 || keywords.indexOf("轮胎") !== -1) {
      return { icon: $r("app.media.carExpenseIcon"), name: "汽车" };
    }
    if (keywords.indexOf("礼物") !== -1 || keywords.indexOf("礼品") !== -1 || keywords.indexOf("送礼") !== -1) {
      return { icon: $r("app.media.giftExpenseIcon"), name: "礼物" };
    }
    if (keywords.indexOf("捐赠") !== -1 || keywords.indexOf("捐款") !== -1 || keywords.indexOf("公益") !== -1 ||
        keywords.indexOf("慈善") !== -1) {
      return { icon: $r("app.media.supportExpenseIcon"), name: "捐赠" };
    }

    // 3. 对于"转账"类型，如果对方名称包含特定关键词，尝试分类
    if (typeStr === "转账" && direction === BillingDirection.OUT) {
      // 转账给个人，默认归为"其他"
      return { icon: $r("app.media.otherIcon"), name: "其他" };
    }

    // 4. 二维码收款 - 收入归为"其它"，支出归为"其他"
    if (typeStr === "二维码收款") {
      return { icon: $r("app.media.otherIcon"), name: "其他" };
    }

    // 5. 默认为"其他"
    return { icon: $r("app.media.otherIcon"), name: "其他" };
  }

  /**
   * 转义 CSV 字段（包含逗号或引号时加引号）
   */
  private static escapeCSV(value: string): string {
    if (value.indexOf(',') !== -1 || value.indexOf('"') !== -1 || value.indexOf('\n') !== -1) {
      return '"' + value.replace(/"/g, '""') + '"';
    }
    return value;
  }

  /**
   * 获取属性值（从并行数组中查找）
   */
  private static getAttr(names: string[], values: string[], key: string): string {
    for (let i = 0; i < names.length; i++) {
      if (names[i] === key) {
        return values[i];
      }
    }
    return "";
  }

  /**
   * 解码 XML 实体
   */
  private static decodeXMLEntities(text: string): string {
    // 解码 XML 实体
    let result = text;
    // 使用 String.fromCharCode 构建实体字符串，避免被格式化工具误转换
    const amp = String.fromCharCode(38) + "amp;";
    const lt = String.fromCharCode(38) + "lt;";
    const gt = String.fromCharCode(38) + "gt;";
    const quot = String.fromCharCode(38) + "quot;";
    const apos = String.fromCharCode(38) + "apos;";
    const n10 = String.fromCharCode(38) + "#10;";
    const n13 = String.fromCharCode(38) + "#13;";
    const nx = String.fromCharCode(38) + "#x([0-9a-fA-F]+);";
    result = result.replace(new RegExp(amp, 'g'), String.fromCharCode(38));
    result = result.replace(new RegExp(lt, 'g'), String.fromCharCode(60));
    result = result.replace(new RegExp(gt, 'g'), String.fromCharCode(62));
    result = result.replace(new RegExp(quot, 'g'), String.fromCharCode(34));
    result = result.replace(new RegExp(apos, 'g'), String.fromCharCode(39));
    result = result.replace(new RegExp(n10, 'g'), '\n');
    result = result.replace(new RegExp(n13, 'g'), '\r');
    result = result.replace(new RegExp(nx, 'g'), (match: string, hex: string) => String.fromCodePoint(parseInt(hex, 16)));
    return result;
  }

  /**
   * 格式化日期
   */
  private static formatDate(date: Date): string {
    const y = date.getFullYear();
    const m = String(date.getMonth() + 1).padStart(2, '0');
    const d = String(date.getDate()).padStart(2, '0');
    const h = String(date.getHours()).padStart(2, '0');
    const min = String(date.getMinutes()).padStart(2, '0');
    const s = String(date.getSeconds()).padStart(2, '0');
    return `${y}-${m}-${d} ${h}:${min}:${s}`;
  }
}
