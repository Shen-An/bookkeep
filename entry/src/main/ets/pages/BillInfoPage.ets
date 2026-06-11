// Copyright (c) 2023 Ericple
// 风风记账 is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
// http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT, MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.
import router from '@ohos.router'
import { BillingDirection, BillingInfo, BillingInfoUtils, CurrencyManager, DBManager, Logger, StringUtils } from '@ohos/common';

let TAG = "BillInfoPage"

interface BillInfoPageParams {
  date?: Date | number | string;
}

@Entry
@Component
struct BillInfoPage {
  @State activeDate: Date = new Date();
  @State monthlySepBillInfo: BillingInfo[][] = [];
  @State yearlyLeft: number = 0;
  @State yearlyOutBill: number = 0;
  @State yearlyIncome: number = 0;
  @State currencySymbol: string = '¥';

  clearCache() {
    this.yearlyLeft = 0;
    this.yearlyOutBill = 0;
    this.yearlyIncome = 0;
  }

  aboutToAppear() {
    const params = router.getParams() as BillInfoPageParams;
    const raw = params?.date;
    if (raw instanceof Date) {
      this.activeDate = raw;
    } else if (typeof raw === 'number') {
      this.activeDate = new Date(raw);
    } else if (typeof raw === 'string') {
      this.activeDate = new Date(raw);
    }
    this.onPageShow();
  }

  onPageShow() {
    CurrencyManager.getInstance().init().then(() => {
      this.currencySymbol = CurrencyManager.getInstance().getSymbol();
    });
    DBManager.getInstance().getAllBillingInfo()
      .then(r => {
        this.clearCache();
        Logger.info(TAG, "activeDate:", StringUtils.formatDate(this.activeDate, 'Y-M-D'))
        this.monthlySepBillInfo = BillingInfoUtils.explodeYearlyArray(r, this.activeDate);
        this.monthlySepBillInfo.forEach(monthlyInfo => {
          monthlyInfo.forEach(info => {
            if (info.direction == BillingDirection.IN) {
              this.yearlyLeft += info.amount;
              this.yearlyIncome += info.amount;
            } else {
              this.yearlyLeft -= info.amount;
              this.yearlyOutBill += info.amount;
            }
          })
        })
      })
  }

  private yearText(): string {
    return `${this.activeDate.getFullYear()}年`;
  }

  private monthLeft(monthlyInfo: BillingInfo[]): number {
    return BillingInfoUtils.calculateTotalLeft(monthlyInfo);
  }

  build() {
    Column() {
      Scroll() {
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
              Text('年度账单')
                .fontSize(24)
                .fontColor(Color.White)
                .fontWeight(FontWeight.Bold)
              Text('你的全年财务概览')
                .fontSize(12)
                .fontColor('#d8efff')
                .margin({ top: 3 })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
            .margin({ left: 12 })

            Button({ type: ButtonType.Normal }) {
              Row() {
                Text(this.yearText())
                  .fontSize(14)
                  .fontColor('#126dff')
                  .fontWeight(FontWeight.Bold)
                Image($r("app.media.ic_public_extract_list_dark"))
                  .width(10)
                  .height(10)
                  .margin({ left: 6 })
              }
            }
            .height(40)
            .padding({ left: 14, right: 14 })
            .backgroundColor(Color.White)
            .borderRadius(18)
            .onClick(() => {
              DatePickerDialog.show({
                start: new Date("2000-01-01"),
                onAccept: (v) => {
                  this.activeDate.setFullYear(v.year, v.month, v.day);
                  this.onPageShow();
                }
              })
            })
          }
          .width('100%')
          .padding({
            left: 18,
            right: 18,
            top: 28,
            bottom: 20
          })
          .linearGradient({
            angle: 145,
            colors: [
              ['#FF2CC4E1', 0],
              [$r('app.color.main_theme_gradient_start'), 0.5],
              [$r('app.color.main_theme_gradient_end'), 1]
            ]
          })

          Column() {
            Column() {
              Column() {
                Text('年结余')
                  .fontSize(13)
                  .fontColor('#d7edff')
                Text(CurrencyManager.formatWithSymbol(this.yearlyLeft, this.currencySymbol))
                  .fontSize(36)
                  .fontColor(Color.White)
                  .fontWeight(FontWeight.Bold)
                  .margin({ top: 8 })
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })

                Row() {
                  Column() {
                    Text('全年收入')
                      .fontSize(12)
                      .fontColor('#6a7c94')
                    Text(CurrencyManager.formatWithSymbol(this.yearlyIncome, this.currencySymbol))
                      .fontSize(18)
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
                    Text('全年支出')
                      .fontSize(12)
                      .fontColor('#6a7c94')
                    Text(CurrencyManager.formatWithSymbol(this.yearlyOutBill, this.currencySymbol))
                      .fontSize(18)
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

              Row() {
                Text('月度表现')
                  .fontSize(20)
                  .fontColor('#1f2a3d')
                  .fontWeight(FontWeight.Bold)
                Blank()
                Text('12个月')
                  .fontSize(12)
                  .fontColor('#8b96a8')
              }
              .width('100%')
              .margin({ top: 24, bottom: 12 })

              Column() {
                ForEach(this.monthlySepBillInfo, (monthlyInfo: BillingInfo[], index: number) => {
                  Row() {
                    Column() {
                      Text(`${index + 1}`)
                        .fontSize(24)
                        .fontColor('#126dff')
                        .fontWeight(FontWeight.Bold)
                      Text('月')
                        .fontSize(11)
                        .fontColor('#8b96a8')
                    }
                    .alignItems(HorizontalAlign.Center)
                    .width(54)
                    .height(58)
                    .backgroundColor('#eef6ff')
                    .borderRadius(18)
                    .margin({ right: 14 })

                    Column() {
                      Text(this.monthLeft(monthlyInfo) >= 0 ? '本月结余为正' : '本月支出较高')
                        .fontSize(15)
                        .fontColor('#1f2a3d')
                        .fontWeight(FontWeight.Bold)
                      Row() {
                        Text(`收 ${CurrencyManager.formatWithSymbol(BillingInfoUtils.calculateTotalIncome(monthlyInfo),
                          this.currencySymbol)}`)
                          .fontSize(12)
                          .fontColor($r('app.color.income_green'))
                        Text(
                          ` 支 ${CurrencyManager.formatWithSymbol(BillingInfoUtils.calculateTotalOutBill(monthlyInfo),
                            this.currencySymbol)}`)
                          .fontSize(12)
                          .fontColor($r('app.color.expense_red'))
                          .margin({ left: 10 })
                      }
                      .margin({ top: 6 })
                    }
                    .alignItems(HorizontalAlign.Start)
                    .layoutWeight(1)

                    Text(CurrencyManager.formatWithSymbol(this.monthLeft(monthlyInfo), this.currencySymbol))
                      .fontSize(15)
                      .fontColor(
                        this.monthLeft(monthlyInfo) >= 0 ? $r('app.color.income_green') : $r('app.color.expense_red'))
                      .fontWeight(FontWeight.Bold)
                  }
                  .width('100%')
                  .padding({
                    left: 14,
                    right: 14,
                    top: 14,
                    bottom: 14
                  })
                  .backgroundColor(Color.White)
                  .borderRadius(22)
                  .margin({ bottom: 10 })
                  .shadow({ radius: 12, color: '#10000000', offsetY: 5 })
                })
              }
              .width('100%')
            }
            .width('100%')
            .padding({
              left: 16,
              right: 16,
              top: 16,
              bottom: 28
            })
            .width('100%')
            .backgroundColor('#f3f7fb')
          }
          .width('100%')
          .backgroundColor('#f3f7fb')
        }
        .width('100%')
        .backgroundColor('#f3f7fb')
      }
      .height('100%')
      .width('100%')
      .backgroundColor('#f3f7fb')
    }
  }
}