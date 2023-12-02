// Copyright (c) 2023 Ericple
// OpenBill is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
// http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT, MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

@Component
export struct PageEntries {
  private selectedDate: Date = new Date();

  build() {
    Row() {
      Flex({ justifyContent: FlexAlign.SpaceAround }) {
        Button({ type: ButtonType.Normal }) {
          Column() {
            Row() {
              Image($r("app.media.ic_public_budget"))
                .width(32)
                .height(32)
            }

            Row() {
              Text("账单")
                .fontSize(10)
                .width('100%')
                .textAlign(TextAlign.Center)
            }.height(12).width(48)
          }.width(48)
        }.backgroundColor(Color.Transparent).borderRadius(8).onClick(() => {
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
                .width(32)
                .height(32)
            }

            Row() {
              Text("开源信息")
                .fontSize(10)
                .width('100%')
                .textAlign(TextAlign.Center)
            }.height(12).width(48)
          }.width(48).alignItems(HorizontalAlign.Center)
        }.backgroundColor(Color.Transparent).onClick(() => {
          router.pushUrl({
            url: 'pages/Copyright'
          }, router.RouterMode.Standard, err => {
            return;
          })
        }).borderRadius(8)

        Button({ type: ButtonType.Normal }) {
          Column() {
            Row() {
              Image($r("app.media.ic_public_billing_graphic"))
                .width(32)
                .height(32)
            }

            Row() {
              Text("经济图表")
                .fontSize(10)
                .width('100%')
                .textAlign(TextAlign.Center)
            }.height(12).width(48)
          }.width(48).alignItems(HorizontalAlign.Center)
        }.backgroundColor(Color.Transparent).borderRadius(8).onClick(() => {
          promptAction.showToast({ message: "待开发" })
        })

        Button({ type: ButtonType.Normal }) {
          Column() {
            Row() {
              Image($r("app.media.ic_public_add_billing"))
                .width(32)
                .height(32)
            }

            Row() {
              Text("记账")
                .fontSize(10)
                .width('100%')
                .textAlign(TextAlign.Center)
            }.height(12).width(48)
          }.width(48).alignItems(HorizontalAlign.Center)
        }.stateEffect(false).backgroundColor(Color.Transparent).onClick(() => {
          router.pushUrl({
            url: "pages/addBalance",
            params: {
              year: this.selectedDate.getFullYear(),
              month: this.selectedDate.getMonth() + 1
            }
          })
        }).borderRadius(8)
      }
      .height(64)
      .width('100%')
      .backgroundColor(Color.White)
      .borderRadius(8)
      .padding(8)
      .shadow({ radius: 24, color: $r('app.color.main_theme_shadow') })
    }.linearGradient({
      angle: 180,
      colors: [
        [$r('app.color.main_theme_blue'), 0],
        ["#ffffff", 1]
      ],
      repeating: false
    }).padding({ top: 16, left: 8, right: 8, bottom: 8 })
  }
}