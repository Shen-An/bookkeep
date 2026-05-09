import router from '@ohos.router';
import { CategoryRatio, DBManager, EconomicStatsUtils, MonthlyEconomyReport, MonthlyTrend } from '@ohos/common';
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
    this.reload();
  }

  onPageShow() {
    this.reload();
  }

  private buildLineSeries(): LineSeries[] {
    const income: LineSeries = {
      name: '收入',
      values: this.trend.income,
      color: '#2CC4E1'
    };
    const expense: LineSeries = {
      name: '支出',
      values: this.trend.expense,
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
    const startText = `${start.getFullYear()}-${start.getMonth() + 1}`;
    const endText = `${end.getFullYear()}-${end.getMonth() + 1}`;
    return `范围：${startText} ~ ${endText}`;
  }

  private toPieSlices(src: CategoryRatio[]): PieSlice[] {
    return src
      .filter(i => i.amount > 0)
      .map((i: CategoryRatio) => {
        const slice: PieSlice = {
          label: i.name,
          value: i.amount,
          percent: i.percent
        };
        return slice;
      });
  }

  private monthTitle(): string {
    const y = this.activeMonth.getFullYear();
    const m = this.activeMonth.getMonth() + 1;
    return `${y}年${m}月`;
  }

  build() {
    Column() {
      // 顶部栏 - 渐变背景
      Row() {
        Text('返回')
          .fontSize(15)
          .fontColor(Color.White)
          .margin({ left: 16, right: 12 })
          .onClick(() => router.back());

        Text('经济图表')
          .fontSize(19)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold);

        Blank();

        Row() {
          Text(this.monthTitle())
            .fontSize(15)
            .fontColor(Color.White);
          Image($r('app.media.ic_public_extract_list_dark'))
            .width(10)
            .height(10)
            .margin({ left: 6 });
        }
        .margin({ right: 16 })
        .padding({ left: 10, right: 10, top: 4, bottom: 4 })
        .backgroundColor('#ffffff33')
        .borderRadius(16)
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
      .padding({ top: 20, bottom: 20 })
      .width('100%')
      .linearGradient({
        angle: 180,
        colors: [
          [$r('app.color.main_theme_gradient_start'), 0],
          [$r('app.color.main_theme_gradient_end'), 1]
        ]
      })

      if (this.loading) {
        Column() {
          Text('加载中...')
            .fontSize(14)
            .fontColor($r('app.color.text_gray'))
            .margin({ top: 32 });
          LoadingProgress()
            .width(32)
            .height(32)
            .color($r('app.color.main_theme_blue'))
            .margin({ top: 12 })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .margin({ top: 80 })
      } else {
        Scroll() {
          Column() {
            // 1) 月度收支趋势折线图
            Column() {
              Row() {
                Image($r('app.media.ic_public_billing_graphic'))
                  .width(20)
                  .height(20)
                  .margin({ right: 6 })
                Text('月度收支趋势')
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#1a1a1a')
              }
              .margin({ bottom: 12 })

              ForEach([this.chartRefreshToken], (_t: number) => {
                LineChart({
                  series: this.buildLineSeries(),
                  chartHeight: 200
                })
              })

              if (this.trendRangeText().length > 0) {
                Text(this.trendRangeText())
                  .fontSize(12)
                  .fontColor($r('app.color.text_gray'))
                  .margin({ top: 6 })
              }

              Row() {
                Row() {
                  Text('●')
                    .fontSize(12)
                    .fontColor('#2CC4E1');
                  Text('收入')
                    .fontSize(12)
                    .margin({ left: 6 })
                    .fontColor($r('app.color.text_gray'));
                }

                Row() {
                  Text('●')
                    .fontSize(12)
                    .fontColor('#1FA1FF');
                  Text('支出')
                    .fontSize(12)
                    .margin({ left: 6 })
                    .fontColor($r('app.color.text_gray'));
                }
              }
              .justifyContent(FlexAlign.SpaceAround)
              .width('100%')
              .margin({ top: 8 });
            }
            .padding(16)
            .margin({ left: 16, right: 16, top: 16 })
            .backgroundColor(Color.White)
            .borderRadius(16)
            .shadow({ radius: 8, color: '#1a000000', offsetY: 2 })

            // 2) 支出分类占比饼图
            Column() {
              Row() {
                Image($r('app.media.ic_public_budget'))
                  .width(20)
                  .height(20)
                  .margin({ right: 6 })
                Text('当月支出分类占比')
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#1a1a1a')
              }
              .margin({ bottom: 12 })

              ForEach([this.chartRefreshToken], (_t: number) => {
                PieChart({
                  slices: this.toPieSlices(this.report.current.expenseCategories),
                  chartHeight: 220
                })
              })

              Column() {
                ForEach(this.report.current.expenseCategories, (i: CategoryRatio) => {
                  Row() {
                    Text(i.name)
                      .fontSize(13)
                      .fontColor('#333333')
                      .width('35%');
                    Text(`¥${i.amount.toFixed(2)}`)
                      .fontSize(13)
                      .fontColor('#1a1a1a')
                      .fontWeight(FontWeight.Medium)
                      .width('35%')
                      .textAlign(TextAlign.End);
                    Text(`${i.percent.toFixed(1)}%`)
                      .fontSize(13)
                      .width('20%')
                      .textAlign(TextAlign.End)
                      .fontColor($r('app.color.main_theme_blue'))
                      .fontWeight(FontWeight.Medium);
                  }
                  .padding({ top: 8, bottom: 8 })
                  .border({
                    width: { bottom: 0.5 },
                    color: $r('app.color.divider_color')
                  })
                })
              }
              .margin({ top: 8 })
            }
            .padding(16)
            .margin({ left: 16, right: 16, top: 12 })
            .backgroundColor(Color.White)
            .borderRadius(16)
            .shadow({ radius: 8, color: '#1a000000', offsetY: 2 })

            // 3) 收入分类占比饼图
            Column() {
              Row() {
                Image($r('app.media.ic_public_add_billing'))
                  .width(20)
                  .height(20)
                  .margin({ right: 6 })
                Text('收入分类占比')
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#1a1a1a')
              }
              .margin({ bottom: 12 })

              ForEach([this.chartRefreshToken], (_t: number) => {
                PieChart({
                  slices: this.toPieSlices(this.report.current.incomeCategories),
                  chartHeight: 220
                })
              })

              Column() {
                ForEach(this.report.current.incomeCategories, (i: CategoryRatio) => {
                  Row() {
                    Text(i.name)
                      .fontSize(13)
                      .fontColor('#333333')
                      .width('35%');
                    Text(`¥${i.amount.toFixed(2)}`)
                      .fontSize(13)
                      .fontColor('#1a1a1a')
                      .fontWeight(FontWeight.Medium)
                      .width('35%')
                      .textAlign(TextAlign.End);
                    Text(`${i.percent.toFixed(1)}%`)
                      .fontSize(13)
                      .width('20%')
                      .textAlign(TextAlign.End)
                      .fontColor($r('app.color.income_green'))
                      .fontWeight(FontWeight.Medium);
                  }
                  .padding({ top: 8, bottom: 8 })
                  .border({
                    width: { bottom: 0.5 },
                    color: $r('app.color.divider_color')
                  })
                })
              }
              .margin({ top: 8 })
            }
            .padding(16)
            .margin({ left: 16, right: 16, top: 12 })
            .backgroundColor(Color.White)
            .borderRadius(16)
            .shadow({ radius: 8, color: '#1a000000', offsetY: 2 })

            // 4) 经济分析文案
            Column() {
              Row() {
                Image($r('app.media.icon'))
                  .width(20)
                  .height(20)
                  .margin({ right: 6 })
                Text('经济分析')
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#1a1a1a')
              }
              .margin({ bottom: 12 })

              Text(this.report.analysisText)
                .fontSize(14)
                .lineHeight(22)
                .fontColor('#555555');
            }
            .padding(16)
            .margin({ left: 16, right: 16, top: 12, bottom: 24 })
            .backgroundColor(Color.White)
            .borderRadius(16)
            .shadow({ radius: 8, color: '#1a000000', offsetY: 2 })
          }
          .width('100%')
          .padding({ bottom: 16 })
        }
      }
    }
    .width('100%')
    .backgroundColor($r('app.color.page_background'))
  }
}
