import router from '@ohos.router';
import { CategoryRatio, DBManager, EconomicStatsUtils, MonthlyEconomyReport, MonthlyTrend, CurrencyManager } from '@ohos/common';
import { LineChart } from '../components/charts/LineChart';
import { PieChart } from '../components/charts/PieChart';
import { LineSeries, PieSlice } from '../components/charts/ChartModels';

interface EconomicChartsParams {
  date?: Date | number | string;
}

@Entry
@Component
struct EconomicCharts {
  @State activeMonth: Date = new Date();
  @State report: MonthlyEconomyReport = EconomicStatsUtils.buildMonthlyReport([], new Date());
  @State trend: MonthlyTrend = EconomicStatsUtils.buildMonthlyTrend([], new Date(), 6);
  @State loading: boolean = true;
  @State chartRefreshToken: number = 0;
  @State currencySymbol: string = '¥';

  private reload(): void {
    this.loading = true;
    DBManager.getInstance().getAllBillingInfo()
      .then(all => {
        this.report = EconomicStatsUtils.buildMonthlyReport(all, this.activeMonth);
        this.trend = EconomicStatsUtils.buildMonthlyTrend(all, this.activeMonth, 6);
        this.chartRefreshToken = this.chartRefreshToken + 1;
        this.loading = false;
      })
      .catch((_e: Error) => {
        this.report = EconomicStatsUtils.buildMonthlyReport([], this.activeMonth);
        this.trend = EconomicStatsUtils.buildMonthlyTrend([], this.activeMonth, 6);
        this.chartRefreshToken = this.chartRefreshToken + 1;
        this.loading = false;
      });
  }

  aboutToAppear() {
    const params = router.getParams() as EconomicChartsParams;
    const now = new Date();
    const raw = params?.date;
    let baseDate: Date = now;
    if (raw instanceof Date) {
      baseDate = raw;
    } else if (typeof raw === 'number') {
      baseDate = new Date(raw);
    } else if (typeof raw === 'string') {
      baseDate = new Date(raw);
    }

    this.activeMonth = new Date(baseDate.getTime());
    this.activeMonth.setDate(1);
    this.activeMonth.setHours(0, 0, 0, 0);
    this.loadCurrencyAndReload();
  }

  onPageShow() {
    this.loadCurrencyAndReload();
  }

  private loadCurrencyAndReload(): void {
    CurrencyManager.getInstance().init().then(() => {
      this.currencySymbol = CurrencyManager.getInstance().getSymbol();
      this.reload();
    });
  }

  private buildLineSeries(): LineSeries[] {
    const income: LineSeries = {
      name: '收入',
      values: this.trend.income.map((v: number) => CurrencyManager.convertWithSymbol(v, this.currencySymbol)),
      color: '#2CC4E1'
    };
    const expense: LineSeries = {
      name: '支出',
      values: this.trend.expense.map((v: number) => CurrencyManager.convertWithSymbol(v, this.currencySymbol)),
      color: '#1FA1FF'
    };
    return [income, expense];
  }

  private trendRangeText(): string {
    const months = this.trend.months;
    if (!months || months.length === 0) {
      return '';
    }
    const start = months[0];
    const end = months[months.length - 1];
    return `${start.getFullYear()}-${start.getMonth() + 1} 至 ${end.getFullYear()}-${end.getMonth() + 1}`;
  }

  private toPieSlices(src: CategoryRatio[]): PieSlice[] {
    return src
      .filter(i => i.amount > 0)
      .map((i: CategoryRatio) => {
        const slice: PieSlice = {
          label: i.name,
          value: CurrencyManager.convertWithSymbol(i.amount, this.currencySymbol),
          percent: i.percent
        };
        return slice;
      });
  }

  private monthTitle(): string {
    return `${this.activeMonth.getFullYear()}年${this.activeMonth.getMonth() + 1}月`;
  }

  @Builder
  private CategoryRows(items: CategoryRatio[], accent: ResourceColor) {
    Column() {
      ForEach(items, (i: CategoryRatio) => {
        Row() {
          Column() {
            Text(i.name)
              .fontSize(14)
              .fontColor('#1f2a3d')
              .fontWeight(FontWeight.Medium)
            Text(`${i.percent.toFixed(1)}%`)
              .fontSize(11)
              .fontColor('#8b96a8')
              .margin({ top: 3 })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Text(CurrencyManager.formatWithSymbol(i.amount, this.currencySymbol))
            .fontSize(14)
            .fontColor(accent)
            .fontWeight(FontWeight.Bold)
        }
        .width('100%')
        .padding({ top: 12, bottom: 12 })
        .border({ width: { bottom: 0.5 }, color: '#eef2f7' })
      })
    }
    .width('100%')
  }

  build() {
    Column() {
      Row() {
        Button({ type: ButtonType.Normal }) {
          Text('‹')
            .fontSize(30)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
        }
        .width(44)
        .height(44)
        .backgroundColor('#24ffffff')
        .borderRadius(16)
        .onClick(() => router.back())

        Column() {
          Text('经济分析')
            .fontSize(24)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
          Text('趋势、结构与风险一屏掌握')
            .fontSize(12)
            .fontColor('#d8efff')
            .margin({ top: 3 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        .margin({ left: 12 })

        Button({ type: ButtonType.Normal }) {
          Row() {
            Text(this.monthTitle())
              .fontSize(13)
              .fontColor('#126dff')
              .fontWeight(FontWeight.Bold)
            Image($r('app.media.ic_public_extract_list_dark'))
              .width(10)
              .height(10)
              .margin({ left: 6 })
          }
        }
        .height(40)
        .padding({ left: 12, right: 12 })
        .backgroundColor(Color.White)
        .borderRadius(18)
        .onClick(() => {
          DatePickerDialog.show({
            start: new Date('2000-01-01'),
            onAccept: (v) => {
              this.activeMonth.setFullYear(v.year, v.month, 1);
              this.activeMonth.setHours(0, 0, 0, 0);
              this.reload();
            }
          })
        })
      }
      .width('100%')
      .padding({ left: 18, right: 18, top: 28, bottom: 20 })
      .linearGradient({
        angle: 145,
        colors: [
          ['#FF2CC4E1', 0],
          [$r('app.color.main_theme_gradient_start'), 0.5],
          [$r('app.color.main_theme_gradient_end'), 1]
        ]
      })

      if (this.loading) {
        Column() {
          LoadingProgress()
            .width(36)
            .height(36)
            .color($r('app.color.main_theme_blue'))
          Text('正在生成分析...')
            .fontSize(14)
            .fontColor('#8b96a8')
            .margin({ top: 14 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column() {
            Column() {
              Text('本月净结余')
                .fontSize(13)
                .fontColor('#d7edff')
              Text(CurrencyManager.formatWithSymbol(this.report.current.leftTotal, this.currencySymbol))
                .fontSize(34)
                .fontColor(Color.White)
                .fontWeight(FontWeight.Bold)
                .margin({ top: 8 })

              Row() {
                Column() {
                  Text('收入')
                    .fontSize(12)
                    .fontColor('#6a7c94')
                  Text(CurrencyManager.formatWithSymbol(this.report.current.incomeTotal, this.currencySymbol))
                    .fontSize(17)
                    .fontColor($r('app.color.income_green'))
                    .fontWeight(FontWeight.Bold)
                    .margin({ top: 6 })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
                .padding(14)
                .backgroundColor('#f6fffb')
                .borderRadius(18)
                .margin({ right: 8 })

                Column() {
                  Text('支出')
                    .fontSize(12)
                    .fontColor('#6a7c94')
                  Text(CurrencyManager.formatWithSymbol(this.report.current.expenseTotal, this.currencySymbol))
                    .fontSize(17)
                    .fontColor($r('app.color.expense_red'))
                    .fontWeight(FontWeight.Bold)
                    .margin({ top: 6 })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
                .padding(14)
                .backgroundColor('#fff8f8')
                .borderRadius(18)
                .margin({ left: 8 })
              }
              .width('100%')
              .margin({ top: 22 })
            }
            .width('100%')
            .padding(22)
            .linearGradient({
              angle: 150,
              colors: [
                [$r('app.color.main_theme_gradient_start'), 0],
                [$r('app.color.main_theme_gradient_end'), 1]
              ]
            })
            .borderRadius(30)
            .shadow({ radius: 22, color: '#330D6EFD', offsetY: 10 })

            Column() {
              Row() {
                Text('半年趋势')
                  .fontSize(20)
                  .fontColor('#1f2a3d')
                  .fontWeight(FontWeight.Bold)
                Blank()
                Text(this.trendRangeText())
                  .fontSize(12)
                  .fontColor('#8b96a8')
              }
              .width('100%')

              ForEach([this.chartRefreshToken], (_t: number) => {
                LineChart({ series: this.buildLineSeries(), chartHeight: 220 })
              })

              Row() {
                Text('● 收入')
                  .fontSize(12)
                  .fontColor('#2CC4E1')
                Text('● 支出')
                  .fontSize(12)
                  .fontColor('#1FA1FF')
                  .margin({ left: 18 })
              }
              .width('100%')
              .justifyContent(FlexAlign.Center)
              .margin({ top: 6 })
            }
            .width('100%')
            .padding(18)
            .backgroundColor(Color.White)
            .borderRadius(28)
            .margin({ top: 18 })
            .shadow({ radius: 16, color: '#12000000', offsetY: 7 })

            Row() {
              Column() {
                Text('支出结构')
                  .fontSize(18)
                  .fontColor('#1f2a3d')
                  .fontWeight(FontWeight.Bold)
                ForEach([this.chartRefreshToken], (_t: number) => {
                  PieChart({ slices: this.toPieSlices(this.report.current.expenseCategories), chartHeight: 180 })
                })
                this.CategoryRows(this.report.current.expenseCategories, $r('app.color.expense_red'))
              }
              .layoutWeight(1)
              .padding(16)
              .backgroundColor(Color.White)
              .borderRadius(26)
              .shadow({ radius: 14, color: '#10000000', offsetY: 6 })

              Column() {
                Text('收入结构')
                  .fontSize(18)
                  .fontColor('#1f2a3d')
                  .fontWeight(FontWeight.Bold)
                ForEach([this.chartRefreshToken], (_t: number) => {
                  PieChart({ slices: this.toPieSlices(this.report.current.incomeCategories), chartHeight: 180 })
                })
                this.CategoryRows(this.report.current.incomeCategories, $r('app.color.income_green'))
              }
              .layoutWeight(1)
              .padding(16)
              .backgroundColor(Color.White)
              .borderRadius(26)
              .margin({ left: 12 })
              .shadow({ radius: 14, color: '#10000000', offsetY: 6 })
            }
            .width('100%')
            .margin({ top: 18 })

            Column() {
              Text('智能解读')
                .fontSize(20)
                .fontColor('#1f2a3d')
                .fontWeight(FontWeight.Bold)
                .width('100%')
              Text(this.report.analysisText)
                .fontSize(14)
                .lineHeight(24)
                .fontColor('#5f6c80')
                .margin({ top: 12 })
            }
            .width('100%')
            .padding(20)
            .backgroundColor(Color.White)
            .borderRadius(28)
            .margin({ top: 18, bottom: 28 })
            .shadow({ radius: 16, color: '#12000000', offsetY: 7 })
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 16 })
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f3f7fb')
  }
}
