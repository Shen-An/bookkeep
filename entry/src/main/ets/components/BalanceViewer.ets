// Copyright (c) 2023 Ericple
// OpenBill is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
// http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT, MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.
import fs from '@ohos.file.fs';
import common from '@ohos.app.ability.common';
import { advancedTemplate } from '../data/defaultBalanceTemplate';
import { StringUtils } from '@ohos/common';

@Component
export struct BalanceViewer {
  @Link selectedDate: Date;
  @Link currentBillingInfo: string;
  @Link totalIncome: number;
  @Link totalBalance: number;

  build() {
    Column() {
      Row() {
        Column() {
          Row() {
            Text(StringUtils.formatDate(this.selectedDate, 'Y')).fontSize(12).fontColor($r('app.color.text_white'))
            Text($r("app.string.year")).fontSize(12).fontColor($r('app.color.text_white'))
          }
        }.width('20%')

        Column() {
          Text($r("app.string.income"))
            .fontColor($r('app.color.text_white'))
            .fontSize(12)
            .textAlign(TextAlign.Start)
            .width('100%')
        }.width('40%').margin({ left: 10 })

        Column() {
          Text($r("app.string.balance"))
            .fontColor($r('app.color.text_white'))
            .fontSize(12)
            .textAlign(TextAlign.Start)
            .width('100%')
        }.width('40%')
      }
      .height(12)
      .width('100%')
      .backgroundColor($r('app.color.main_theme_blue'))

      Row() {
        Column() {
          Button({ type: ButtonType.Normal }) {
            Row() {
              Text(StringUtils.formatDate(this.selectedDate, 'M'))
                .fontSize(22)
                .fontColor(Color.White)
              Text($r("app.string.month"))
                .fontColor($r('app.color.text_white'))
                .fontSize(12)
                .align(Alignment.Bottom)
                .height(22)
                .margin(2)
              Image($r("app.media.ic_public_extract_list_light"))
                .width(8).height(8).margin({ top: 6, left: 8 })
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
          .backgroundColor($r('app.color.main_theme_blue'))
          .width('100%')
          .borderRadius(4)
        }
        .width('20%')
        .border({
          style: BorderStyle.Solid,
          color: { right: "gray" },
          width: { right: 1 }
        })

        Column() {
          Text(this.totalIncome.toFixed(2))
            .fontColor(Color.White)
            .fontSize(20)
            .textAlign(TextAlign.Start)
            .width('100%')
        }.width('40%')
        .margin({ left: 10 })

        Column() {
          Text(this.totalBalance.toFixed(2))
            .fontColor(Color.White)
            .fontSize(20)
            .textAlign(TextAlign.Start)
            .width('100%')
        }.width('40%')
      }
      .height(52)
      .width('100%')
      .backgroundColor($r('app.color.main_theme_blue'))
      .padding(8)
    }.width('100%')
  }
}