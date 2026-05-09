// Copyright (c) 2023 Ericple
// OpenBill is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
// http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT, MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.
import router from '@ohos.router';

@Component
export struct PageEntries {
  @Link selectedDate: Date;

  build() {
    Column() {
      Flex({ justifyContent: FlexAlign.SpaceAround }) {
        Button({ type: ButtonType.Normal }) {
          Column() {
            Row() {
              Image($r("app.media.ic_public_budget"))
                .width(28)
                .height(28)
            }
            .width(44)
            .height(44)
            .backgroundColor('#f0f7ff')
            .borderRadius(22)
            .justifyContent(FlexAlign.Center)

            Row() {
              Text("年度账单")
                .fontSize(11)
                .fontColor('#333333')
                .width('100%')
                .textAlign(TextAlign.Center)
            }.height(16).width(56)
          }.width(56).alignItems(HorizontalAlign.Center)
        }.backgroundColor(Color.Transparent).borderRadius(12).onClick(() => {
          router.pushUrl({
            url: "pages/BillInfoPage",
            params: {
              date: this.selectedDate
            }
          });
        })

        Button({ type: ButtonType.Normal }) {
          Column() {
            Row() {
              Image($r("app.media.ic_public_opensource_info"))
                .width(28)
                .height(28)
            }
            .width(44)
            .height(44)
            .backgroundColor('#fff0f0')
            .borderRadius(22)
            .justifyContent(FlexAlign.Center)

            Row() {
              Text("开源信息")
                .fontSize(11)
                .fontColor('#333333')
                .width('100%')
                .textAlign(TextAlign.Center)
            }.height(16).width(56)
          }.width(56).alignItems(HorizontalAlign.Center)
        }.backgroundColor(Color.Transparent).onClick(() => {
          router.pushUrl({
            url: 'pages/Copyright'
          }, router.RouterMode.Standard, err => {
            return;
          })
        }).borderRadius(12)

        Button({ type: ButtonType.Normal }) {
          Column() {
            Row() {
              Image($r("app.media.ic_public_billing_graphic"))
                .width(28)
                .height(28)
            }
            .width(44)
            .height(44)
            .backgroundColor('#f5f0ff')
            .borderRadius(22)
            .justifyContent(FlexAlign.Center)

            Row() {
              Text("经济图表")
                .fontSize(11)
                .fontColor('#333333')
                .width('100%')
                .textAlign(TextAlign.Center)
            }.height(16).width(56)
          }.width(56).alignItems(HorizontalAlign.Center)
        }.backgroundColor(Color.Transparent).borderRadius(12).onClick(() => {
          router.pushUrl({
            url: 'pages/EconomicCharts',
            params: {
              date: this.selectedDate
            }
          })
        })

        Button({ type: ButtonType.Normal }) {
          Column() {
            Row() {
              Image($r("app.media.ic_public_add_billing"))
                .width(28)
                .height(28)
            }
            .width(44)
            .height(44)
            .backgroundColor('#f0fff4')
            .borderRadius(22)
            .justifyContent(FlexAlign.Center)

            Row() {
              Text("AI记账")
                .fontSize(11)
                .fontColor('#333333')
                .width('100%')
                .textAlign(TextAlign.Center)
            }.height(16).width(56)
          }.width(56).alignItems(HorizontalAlign.Center)
        }.stateEffect(false).backgroundColor(Color.Transparent).onClick(() => {
          router.pushUrl({
            url: "pages/addBalance",
            params: {
              year: this.selectedDate.getFullYear(),
              month: this.selectedDate.getMonth() + 1,
              day: this.selectedDate.getDate(),
              mode: 'ai'
            }
          })
        }).borderRadius(12)

        Button({ type: ButtonType.Normal }) {
          Column() {
            Row() {
              Image($r("app.media.icon"))
                .width(28)
                .height(28)
            }
            .width(44)
            .height(44)
            .backgroundColor('#fff8e8')
            .borderRadius(22)
            .justifyContent(FlexAlign.Center)

            Row() {
              Text("手动记账")
                .fontSize(11)
                .fontColor('#333333')
                .width('100%')
                .textAlign(TextAlign.Center)
            }.height(16).width(56)
          }.width(56).alignItems(HorizontalAlign.Center)
        }.stateEffect(false).backgroundColor(Color.Transparent).onClick(() => {
          router.pushUrl({
            url: "pages/addBalance",
            params: {
              year: this.selectedDate.getFullYear(),
              month: this.selectedDate.getMonth() + 1,
              day: this.selectedDate.getDate(),
              mode: 'manual'
            }
          })
        }).borderRadius(12)
      }
      .height(80)
      .width('100%')
      .backgroundColor(Color.White)
      .borderRadius(16)
      .padding({ top: 8, bottom: 8 })
      .shadow({
        radius: 8,
        color: '#1a000000',
        offsetY: 2
      })
    }
    .padding({ left: 12, right: 12, bottom: 8 })
  }
}
