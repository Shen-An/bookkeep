// Copyright (c) 2023 Ericple
// 风风记账 is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
// http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT, MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.
import fs from '@ohos.file.fs';
import common from '@ohos.app.ability.common';
import { advancedTemplate } from '../data/defaultBalanceTemplate';
import { BillingInfo, StringUtils } from '@ohos/common';

@Component
export struct BalanceViewer {
  @Link selectedDate: Date;
  @Link currentBillingInfo: BillingInfo[];
  @Link totalIncome: number;
  @Link totalBalance: number;

  build() {
    Column() {
      // 顶部行：年份 + 收入/支出标签
      Row() {
        Column() {
          Row() {
            Text(StringUtils.formatDate(this.selectedDate, 'Y'))
              .fontSize(13)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Medium)
            Text($r("app.string.year"))
              .fontSize(13)
              .fontColor('#ffffffcc')
          }
        }.width('20%')

        Column() {
          Text($r("app.string.income"))
            .fontColor('#ffffffcc')
            .fontSize(12)
            .textAlign(TextAlign.Start)
            .width('100%')
        }.width('40%').margin({ left: 10 })

        Column() {
          Text($r("app.string.balance"))
            .fontColor('#ffffffcc')
            .fontSize(12)
            .textAlign(TextAlign.Start)
            .width('100%')
        }.width('40%')
      }
      .height(16)
      .width('100%')

      // 数值行
      Row() {
        // 月份选择器
        Column() {
          Button({ type: ButtonType.Normal }) {
            Row() {
              Text(StringUtils.formatDate(this.selectedDate, 'M'))
                .fontSize(28)
                .fontColor(Color.White)
                .fontWeight(FontWeight.Bold)
              Text($r("app.string.month"))
                .fontColor('#ffffffb3')
                .fontSize(13)
                .align(Alignment.Bottom)
                .height(22)
                .margin({ left: 2, bottom: 3 })
              Image($r("app.media.ic_public_extract_list_light"))
                .width(10).height(10).margin({ top: 8, left: 4 })
            }
          }.onClick(() => {
            DatePickerDialog.show({
              start: new Date(`2000-01-01`),
              selected: this.selectedDate,
              onAccept: (v) => {
                this.selectedDate.setFullYear(v.year, v.month, v.day);
              }
            });
          })
          .backgroundColor(Color.Transparent)
          .width('100%')
          .borderRadius(8)
        }
        .width('20%')

        // 收入金额
        Column() {
          Text(this.totalIncome.toFixed(2))
            .fontColor(Color.White)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Start)
            .width('100%')
        }.width('40%')
        .margin({ left: 10 })

        // 支出金额
        Column() {
          Text(this.totalBalance.toFixed(2))
            .fontColor(Color.White)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Start)
            .width('100%')
        }.width('40%')
      }
      .height(64)
      .width('100%')
      .padding({ left: 8, right: 8, bottom: 4 })
    }
    .width('100%')
    .padding({ top: 4, bottom: 8 })
    .linearGradient({
      angle: 180,
      colors: [
        [$r('app.color.main_theme_gradient_start'), 0],
        [$r('app.color.main_theme_gradient_end'), 1]
      ]
    })
    .shadow({
      radius: 8,
      color: $r('app.color.main_theme_shadow'),
      offsetY: 2
    })
  }
}