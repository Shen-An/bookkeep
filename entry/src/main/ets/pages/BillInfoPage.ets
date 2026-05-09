// Copyright (c) 2023 Ericple
// OpenBill is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
// http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT, MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.
import router from '@ohos.router'
import { BillingDirection, BillingInfo, BillingInfoUtils, DBManager, Logger, StringUtils } from '@ohos/common';

let TAG = "BillInfoPage"

@Entry
@Component
struct BillInfoPage {
  @State activeDate: Date = new Date();
  @State monthlySepBillInfo: BillingInfo[][] = [];
  @State yearlyLeft: number = 0;
  @State yearlyOutBill: number = 0;
  @State yearlyIncome: number = 0;

  clearCache() {
    this.yearlyLeft = 0;
    this.yearlyOutBill = 0;
    this.yearlyIncome = 0;
  }

  onPageShow() {
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

  build() {
    Column() {
      // 顶部栏 - 渐变背景
      Row() {
        Text('返回')
          .fontSize(15)
          .fontColor(Color.White)
          .margin({ left: 16, right: 12 })
          .onClick(() => router.back());

        Blank();

        Row() {
          Text(`${this.activeDate.getFullYear()}`)
            .fontSize(17)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
          Text($r("app.string.year"))
            .fontSize(14)
            .fontColor('#ffffffcc')
          Image($r("app.media.ic_public_extract_list_light"))
            .width(10)
            .height(10)
            .margin({ left: 6 })
        }
        .margin({ right: 16 })
        .padding({ left: 12, right: 12, top: 4, bottom: 4 })
        .backgroundColor('#ffffff33')
        .borderRadius(16)
        .onClick(() => {
          DatePickerDialog.show({
            start: new Date("2000-01-01"),
            onAccept: (v) => {
              this.activeDate.setFullYear(v.year, v.month, v.day);
            }
          })
        })

        Blank();
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

      // 年度概览卡片
      Row() {
        Column() {
          Text("年结余")
            .fontSize(14)
            .fontColor('#ffffffcc')
            .margin({ bottom: 4 })

          Text(`${this.yearlyLeft.toFixed(2)}`)
            .fontSize(32)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 8 })

          Row() {
            Column() {
              Text('年收入')
                .fontColor('#ffffffb3')
                .fontSize(13)
              Text(`${this.yearlyIncome.toFixed(2)}`)
                .fontColor(Color.White)
                .fontSize(15)
                .fontWeight(FontWeight.Medium)
                .margin({ top: 2 })
            }
            .layoutWeight(1)

            Column() {
              Text('年支出')
                .fontColor('#ffffffb3')
                .fontSize(13)
              Text(`${this.yearlyOutBill.toFixed(2)}`)
                .fontColor(Color.White)
                .fontSize(15)
                .fontWeight(FontWeight.Medium)
                .margin({ top: 2 })
            }
            .layoutWeight(1)
          }
          .width('100%')
        }
        .padding({ left: 24, right: 24, top: 20, bottom: 20 })
      }
      .width('100%')
      .margin({ left: 16, right: 16 })
      .linearGradient({
        angle: 135,
        colors: [
          [$r('app.color.main_theme_gradient_start'), 0],
          [$r('app.color.main_theme_gradient_end'), 1]
        ]
      })
      .borderRadius(16)
      .shadow({
        radius: 12,
        color: '#333a9df0',
        offsetY: 4
      })

      // 月度明细表
      Column() {
        // 表头
        Row() {
          Row() {
            Text("月份")
              .fontSize(13)
              .fontColor($r("app.color.text_gray"))
              .fontWeight(FontWeight.Medium)
          }
          .layoutWeight(1)

          Row() {
            Text("月收入")
              .fontSize(13)
              .fontColor($r("app.color.text_gray"))
              .fontWeight(FontWeight.Medium)
          }
          .layoutWeight(1)

          Row() {
            Text("月支出")
              .fontSize(13)
              .fontColor($r("app.color.text_gray"))
              .fontWeight(FontWeight.Medium)
          }
          .layoutWeight(1)

          Row() {
            Text("月结余")
              .fontSize(13)
              .fontColor($r("app.color.text_gray"))
              .fontWeight(FontWeight.Medium)
          }
          .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: 12, right: 12, bottom: 8 })

        Divider()
          .color($r('app.color.divider_color'))
          .margin({ bottom: 4 })

        // 列表
        List() {
          ForEach(this.monthlySepBillInfo, (monthlyInfo: BillingInfo[], index: number) => {
            ListItem() {
              Row() {
                Row() {
                  Text(`${index + 1}月`)
                    .fontSize(15)
                    .fontColor('#1a1a1a')
                    .fontWeight(FontWeight.Medium)
                }
                .layoutWeight(1)

                Row() {
                  Text(`${BillingInfoUtils.calculateTotalIncome(monthlyInfo).toFixed(2)}`)
                    .fontSize(14)
                    .fontColor($r('app.color.income_green'))
                }
                .layoutWeight(1)

                Row() {
                  Text(`${BillingInfoUtils.calculateTotalOutBill(monthlyInfo).toFixed(2)}`)
                    .fontSize(14)
                    .fontColor($r('app.color.expense_red'))
                }
                .layoutWeight(1)

                Row() {
                  Text(`${BillingInfoUtils.calculateTotalLeft(monthlyInfo).toFixed(2)}`)
                    .fontSize(14)
                    .fontColor(BillingInfoUtils.calculateTotalLeft(monthlyInfo) >= 0 ? $r('app.color.income_green') : $r('app.color.expense_red'))
                    .fontWeight(FontWeight.Medium)
                }
                .layoutWeight(1)
              }
              .width('100%')
              .padding({ left: 12, right: 12, top: 14, bottom: 14 })
              .border({
                width: { bottom: 0.5 },
                color: $r('app.color.divider_color')
              })
            }
          })
        }
        .listDirection(Axis.Vertical)
        .width('100%')
      }
      .padding(16)
      .margin({ left: 16, right: 16, top: 16, bottom: 24 })
      .backgroundColor(Color.White)
      .borderRadius(16)
      .shadow({
        radius: 8,
        color: '#1a000000',
        offsetY: 2
      })
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }
}