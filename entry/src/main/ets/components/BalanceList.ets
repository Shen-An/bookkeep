// Copyright (c) 2023 Ericple
// OpenBill is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
// http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT, MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.
import common from '@ohos.app.ability.common';
import { BillingDirection, BillingInfo, BillingInfoUtils, StringUtils } from '@ohos/common';

@Component
export struct BalanceList {
  @Link currentBillingInfo: BillingInfo[];
  @Link selectedDate: Date;
  @Link totalBalance: number;
  @Link totalIncome: number;
  context = getContext(this) as common.UIAbilityContext;
  filesDir = this.context.filesDir;
  // calculateTotalIncomeBalance = (source: string) => {
  //   const billingInfo = JSON.parse(source);
  //   this.totalBalance = 0.00;
  //   this.totalIncome = 0.00;
  //   billingInfo.forEach(dayInfo => {
  //     dayInfo.forEach(info => {
  //       if (info.direction == "in") {
  //         this.totalIncome += parseFloat(info.amount);
  //       } else {
  //         this.totalBalance += parseFloat(info.amount);
  //       }
  //     })
  //   })
  // }
  // calculateSingleDayBalance = (dayInfo: any) => {
  //   let sdTotalBalance = 0;
  //   dayInfo.forEach(info => {
  //     if (info.direction == "out") {
  //       sdTotalBalance += parseFloat(info.amount);
  //     }
  //   })
  //   return sdTotalBalance;
  // }
  // getDayOfWeek = (day: number) => {
  //   switch (day) {
  //     case 0:
  //       return $r("app.string.day_of_week_sunday");
  //     case 1:
  //       return $r("app.string.day_of_week_monday");
  //     case 2:
  //       return $r("app.string.day_of_week_tuesday");
  //     case 3:
  //       return $r("app.string.day_of_week_wednesday");
  //     case 4:
  //       return $r("app.string.day_of_week_wednesday");
  //     case 5:
  //       return $r("app.string.day_of_week_friday");
  //     case 6:
  //       return $r("app.string.day_of_week_saturday");
  //   }
  // }

  build() {
    Column() {
      if (this.currentBillingInfo.length == 0) {
        Row() {
          Text($r("app.string.no_record"))
            .fontColor(Color.Black)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
        }.height('100%')
      } else {
        List() {
          ForEach(BillingInfoUtils.explodeMonthlyArray(this.currentBillingInfo, this.selectedDate), (balances: BillingInfo[], day: number) => {
            ListItem() {
              Column() {
                if (balances.length > 0) {
                  Text(StringUtils.formatDate(this.selectedDate, 'M月') + `${day + 1}` + "日")
                    .fontColor($r('app.color.text_gray'))
                    .fontSize(14)
                    .width('100%')
                    .margin({ bottom: 4 })
                  Divider()
                    .margin({ bottom: 12 })
                }
                List() {
                  ForEach(balances, (balance: BillingInfo) => {
                    ListItem() {
                      Row() {
                        Row() {
                          Image(balance.type.icon)
                            .width(36)
                            .height(36)
                            .borderRadius(8)
                            .padding(8)
                            .backgroundColor('#ffe2effd')
                            .margin({ right: 16 })
                          Text(balance.remark)
                            .margin({ right: 16 })
                          Text(StringUtils.formatDate(balance.timestamp, 'h:m:s'))
                            .fontColor($r('app.color.text_gray'))
                            .fontSize(12)
                        }

                        Text(`${balance.direction == BillingDirection.IN ? "+" : "-"} ${balance.amount}`)
                      }
                      .width('100%')
                      .justifyContent(FlexAlign.SpaceBetween)
                    }
                    .margin({ bottom: 12 })
                  })
                }
              }
              .width('100%')
            }
          })
        }
        .listDirection(Axis.Vertical)
        .height('100%')
      }
    }.padding(8).width('100%')
  }
}