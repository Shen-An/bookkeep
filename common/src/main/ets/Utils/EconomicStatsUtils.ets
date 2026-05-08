import { BillingDirection, BillingInfo } from '../DataTypes/BillingInfo';

export interface CategoryRatio {
  name: string;
  amount: number;
  percent: number; // 0-100
}

export interface MonthlyEconomyStats {
  monthStart: Date;
  monthEnd: Date;
  dayCount: number;
  incomeTotal: number;
  expenseTotal: number;
  leftTotal: number;
  dailyIncome: number[]; // index: day-1
  dailyExpense: number[]; // index: day-1
  incomeCategories: CategoryRatio[];
  expenseCategories: CategoryRatio[];
  topExpenseCategory?: CategoryRatio;
}

export interface MonthlyEconomyReport {
  month: Date;
  current: MonthlyEconomyStats;
  previous: MonthlyEconomyStats;
  incomeChangePercent?: number;
  expenseChangePercent?: number;
  analysisText: string;
}

export interface MonthlyTrend {
  months: Date[]; // ascending
  income: number[];
  expense: number[];
}

export interface MonthRange {
  start: Date;
  end: Date;
  dayCount: number;
}

interface HighExpenseDay {
  v: number;
  day: number;
}

interface MonthTotals {
  income: number;
  expense: number;
}

export class EconomicStatsUtils {
  private static normalizeMonth(month: Date): Date {
    const ret = new Date(month.getTime());
    ret.setDate(1);
    ret.setHours(0, 0, 0, 0);
    return ret;
  }

  private static getMonthRange(month: Date): MonthRange {
    const start = EconomicStatsUtils.normalizeMonth(month);
    const end = new Date(start.getTime());
    end.setMonth(end.getMonth() + 1);
    const dayCount = new Date(end.getTime() - 1).getDate();
    const ret: MonthRange = { start, end, dayCount };
    return ret;
  }

  private static safePercentChange(current: number, previous: number): number | undefined {
    if (previous === 0) {
      return undefined;
    }
    return (current - previous) / previous * 100;
  }

  private static groupByCategory(src: BillingInfo[], direction: BillingDirection, total: number): CategoryRatio[] {
    const map = new Map<string, number>();
    src.forEach((info) => {
      if (info.direction !== direction) {
        return;
      }
      const name = (info.type?.name && info.type.name.length > 0) ? info.type.name : '未分类';
      map.set(name, (map.get(name) ?? 0) + info.amount);
    });

    const list: CategoryRatio[] = Array.from(map.entries())
      .map((entry) => {
        const name: string = entry[0];
        const amount: number = entry[1];
        const item: CategoryRatio = {
          name,
          amount,
          percent: total > 0 ? amount / total * 100 : 0
        };
        return item;
      })
      .sort((a, b) => b.amount - a.amount);

    // 控制饼图切片数量：保留前 6，其余合并为“其他”，避免标签/图例过长
    const MAX_SLICES = 6;
    if (list.length > MAX_SLICES) {
      const top = list.slice(0, MAX_SLICES);
      const rest = list.slice(MAX_SLICES);
      const restAmount = rest.reduce((sum, i) => sum + i.amount, 0);
      const other: CategoryRatio = {
        name: '其他',
        amount: restAmount,
        percent: total > 0 ? restAmount / total * 100 : 0
      };
      top.push(other);
      return top;
    }

    return list;
  }

  public static buildMonthlyStats(all: BillingInfo[], month: Date): MonthlyEconomyStats {
    const range: MonthRange = EconomicStatsUtils.getMonthRange(month);
    const start: Date = range.start;
    const end: Date = range.end;
    const dayCount: number = range.dayCount;
    const inMonth = all.filter((i) => i.timestamp >= start.getTime() && i.timestamp < end.getTime());

    const dailyIncome: number[] = new Array(dayCount).fill(0);
    const dailyExpense: number[] = new Array(dayCount).fill(0);

    let incomeTotal = 0;
    let expenseTotal = 0;

    inMonth.forEach((info) => {
      const dayIndex = Math.max(0, Math.min(dayCount - 1, new Date(info.timestamp).getDate() - 1));
      if (info.direction === BillingDirection.IN) {
        incomeTotal += info.amount;
        dailyIncome[dayIndex] += info.amount;
      } else {
        expenseTotal += info.amount;
        dailyExpense[dayIndex] += info.amount;
      }
    });

    const leftTotal = incomeTotal - expenseTotal;

    const incomeCategories = EconomicStatsUtils.groupByCategory(inMonth, BillingDirection.IN, incomeTotal);
    const expenseCategories = EconomicStatsUtils.groupByCategory(inMonth, BillingDirection.OUT, expenseTotal);

    const topExpenseCategory = expenseCategories.length > 0 ? expenseCategories[0] : undefined;

    const ret: MonthlyEconomyStats = {
      monthStart: start,
      monthEnd: end,
      dayCount,
      incomeTotal,
      expenseTotal,
      leftTotal,
      dailyIncome,
      dailyExpense,
      incomeCategories,
      expenseCategories,
      topExpenseCategory
    };
    return ret;
  }

  private static detectAnomaly(current: MonthlyEconomyStats): string {
    if (current.expenseTotal <= 0) {
      return '暂无支出数据，未发现异常消费。';
    }

    const avgDailyExpense = current.expenseTotal / current.dayCount;
    const highExpenseDays: HighExpenseDay[] = current.dailyExpense
      .map((v: number, idx: number) => {
        const item: HighExpenseDay = { v: v, day: idx + 1 };
        return item;
      })
      .filter((d: HighExpenseDay) => avgDailyExpense > 0 && d.v >= avgDailyExpense * 2);

    const top = current.topExpenseCategory;
    const topHint = top
      ? `支出最高分类为「${top.name}」（¥${top.amount.toFixed(2)}，占比 ${top.percent.toFixed(1)}%）。`
      : '暂无分类支出数据。';

    let anomalyHint = '未发现明显异常消费。';
    if (highExpenseDays.length > 0) {
      const days = highExpenseDays.slice(0, 3).map(d => `${d.day}日`).join('、');
      anomalyHint = `本月有 ${highExpenseDays.length} 天支出显著高于日均值（例如：${days}）。建议回看这些日期的账单明细。`;
    } else if (top && top.percent >= 60) {
      anomalyHint = `支出较集中于「${top.name}」，建议给该类目设置预算上限，避免超支。`;
    }

    return `${topHint}${anomalyHint}`;
  }

  public static buildMonthlyReport(all: BillingInfo[], month: Date): MonthlyEconomyReport {
    const normalized = EconomicStatsUtils.normalizeMonth(month);
    const previousMonth = new Date(normalized.getTime());
    previousMonth.setMonth(previousMonth.getMonth() - 1);

    const current = EconomicStatsUtils.buildMonthlyStats(all, normalized);
    const previous = EconomicStatsUtils.buildMonthlyStats(all, previousMonth);

    const incomeChangePercent = EconomicStatsUtils.safePercentChange(current.incomeTotal, previous.incomeTotal);
    const expenseChangePercent = EconomicStatsUtils.safePercentChange(current.expenseTotal, previous.expenseTotal);

    const incomeChangeText = incomeChangePercent === undefined
      ? '上月无收入数据，暂不计算收入环比。'
      : `收入环比 ${incomeChangePercent >= 0 ? '+' : ''}${incomeChangePercent.toFixed(1)}%。`;

    const expenseChangeText = expenseChangePercent === undefined
      ? '上月无支出数据，暂不计算支出环比。'
      : `支出环比 ${expenseChangePercent >= 0 ? '+' : ''}${expenseChangePercent.toFixed(1)}%。`;

    const anomaly = EconomicStatsUtils.detectAnomaly(current);

    const analysisText = [
      `本月总收入 ¥${current.incomeTotal.toFixed(2)}，总支出 ¥${current.expenseTotal.toFixed(2)}，结余 ¥${current.leftTotal.toFixed(2)}。`,
      incomeChangeText,
      expenseChangeText,
      anomaly
    ].join('\n');

    const ret: MonthlyEconomyReport = {
      month: normalized,
      current,
      previous,
      incomeChangePercent,
      expenseChangePercent,
      analysisText
    };

    return ret;
  }

  public static buildMonthlyTrend(all: BillingInfo[], endMonth: Date, monthsCount: number = 6): MonthlyTrend {
    const safeCount = Math.max(1, Math.min(24, monthsCount));
    const end = EconomicStatsUtils.normalizeMonth(endMonth);

    // 先把所有账单按 YYYY-M key 聚合，避免每个月都 filter 一遍全量数据
    const totalsMap = new Map<string, MonthTotals>();
    for (let i = 0; i < all.length; i++) {
      const info = all[i];
      const d = new Date(info.timestamp);
      const key = `${d.getFullYear()}-${d.getMonth()}`;
      let totals = totalsMap.get(key);
      if (!totals) {
        totals = { income: 0, expense: 0 };
        totalsMap.set(key, totals);
      }
      if (info.direction === BillingDirection.IN) {
        totals.income += info.amount;
      } else {
        totals.expense += info.amount;
      }
    }

    const months: Date[] = [];
    const income: number[] = [];
    const expense: number[] = [];
    for (let offset = safeCount - 1; offset >= 0; offset--) {
      const m = new Date(end.getTime());
      m.setMonth(m.getMonth() - offset);
      m.setDate(1);
      m.setHours(0, 0, 0, 0);

      const key = `${m.getFullYear()}-${m.getMonth()}`;
      const totals = totalsMap.get(key);
      months.push(m);
      income.push(totals ? totals.income : 0);
      expense.push(totals ? totals.expense : 0);
    }

    const ret: MonthlyTrend = {
      months,
      income,
      expense
    };
    return ret;
  }
}
