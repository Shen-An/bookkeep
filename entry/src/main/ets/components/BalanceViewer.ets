// Copyright (c) 2023 Ericple
// 风风记账 is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
// http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT, MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.
import { BillingInfo, StringUtils, CurrencyManager } from '@ohos/common';

@Component
export struct BalanceViewer {
  @Link selectedDate: Date;
  @Link currentBillingInfo: BillingInfo[];
  @Link totalIncome: number;
  @Link totalBalance: number;
  @Prop currencySymbol: string = '¥';

  private netBalance(): number {
    return this.totalIncome - this.totalBalance;
  }

  private monthlyCount(): number {
    const selectedYear = this.selectedDate.getFullYear();
    const selectedMonth = this.selectedDate.getMonth();
    return this.currentBillingInfo.filter((info: BillingInfo) => {
      const infoDate = new Date(info.timestamp);
      return infoDate.getFullYear() === selectedYear && infoDate.getMonth() === selectedMonth;
    }).length;
  }

  build() {
    Column() {
      Row() {
        Column() {
          Text('本月结余')
            .fontSize(13)
            .fontColor('#d9efff')
            .fontWeight(FontWeight.Medium)

          Text(CurrencyManager.formatWithSymbol(this.netBalance(), this.currencySymbol))
            .fontSize(34)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
            .margin({ top: 6 })
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text(`${StringUtils.formatDate(this.selectedDate, 'Y')}年 · ${this.monthlyCount()} 笔记录`)
            .fontSize(12)
            .fontColor('#c9e7ff')
            .margin({ top: 6 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Button({ type: ButtonType.Normal }) {
          Column() {
            Text(StringUtils.formatDate(this.selectedDate, 'M'))
              .fontSize(28)
              .fontColor('#126dff')
              .fontWeight(FontWeight.Bold)
            Text($r("app.string.month"))
              .fontSize(12)
              .fontColor('#5d8cff')
              .margin({ top: 1 })
          }
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.Center)
        }
        .width(72)
        .height(72)
        .backgroundColor(Color.White)
        .borderRadius(24)
        .shadow({ radius: 12, color: '#22000000', offsetY: 6 })
        .onClick(() => {
          DatePickerDialog.show({
            start: new Date(`2000-01-01`),
            selected: this.selectedDate,
            onAccept: (v) => {
              this.selectedDate.setFullYear(v.year, v.month, v.day);
            }
          });
        })
      }
      .width('100%')

      Row() {
        Column() {
          Text($r("app.string.income"))
            .fontSize(12)
            .fontColor('#6a7c94')
          Text(CurrencyManager.formatWithSymbol(this.totalIncome, this.currencySymbol))
            .fontSize(18)
            .fontColor($r('app.color.income_green'))
            .fontWeight(FontWeight.Bold)
            .margin({ top: 6 })
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        .padding({ left: 16, right: 12, top: 14, bottom: 14 })
        .backgroundColor('#f7fffb')
        .borderRadius(18)
        .margin({ right: 8 })

        Column() {
          Text($r("app.string.balance"))
            .fontSize(12)
            .fontColor('#6a7c94')
          Text(CurrencyManager.formatWithSymbol(this.totalBalance, this.currencySymbol))
            .fontSize(18)
            .fontColor($r('app.color.expense_red'))
            .fontWeight(FontWeight.Bold)
            .margin({ top: 6 })
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        .padding({ left: 16, right: 12, top: 14, bottom: 14 })
        .backgroundColor('#fff8f8')
        .borderRadius(18)
        .margin({ left: 8 })
      }
      .width('100%')
      .margin({ top: 18 })
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 22, bottom: 22 })
    .linearGradient({
      angle: 145,
      colors: [
        ['#FF2CC4E1', 0],
        [$r('app.color.main_theme_gradient_start'), 0.48],
        [$r('app.color.main_theme_gradient_end'), 1]
      ]
    })
    .borderRadius({ bottomLeft: 30, bottomRight: 30 })
    .shadow({ radius: 22, color: '#330D6EFD', offsetY: 8 })
  }
}
