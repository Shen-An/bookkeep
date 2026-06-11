// Copyright (c) 2023 Ericple
// 风风记账 is licensed under Mulan PSL v2.
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
      // 第一行：原有功能入口
      Flex({ justifyContent: FlexAlign.SpaceAround }) {
        Button({ type: ButtonType.Normal }) {
          Column() {
            Row() {
              Image($r("app.media.ic_public_budget"))
                .width(26)
                .height(26)
            }
            .width(46)
            .height(46)
            .backgroundColor('#f0f7ff')
            .borderRadius(23)
            .justifyContent(FlexAlign.Center)

            Row() {
              Text("年度账单")
                .fontSize(12)
                .fontColor('#2f3747')
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
                .width(26)
                .height(26)
            }
            .width(46)
            .height(46)
            .backgroundColor('#fff0f0')
            .borderRadius(23)
            .justifyContent(FlexAlign.Center)

            Row() {
              Text("开源信息")
                .fontSize(12)
                .fontColor('#2f3747')
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
                .width(26)
                .height(26)
            }
            .width(46)
            .height(46)
            .backgroundColor('#f5f0ff')
            .borderRadius(23)
            .justifyContent(FlexAlign.Center)

            Row() {
              Text("经济图表")
                .fontSize(12)
                .fontColor('#2f3747')
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
                .width(26)
                .height(26)
            }
            .width(46)
            .height(46)
            .backgroundColor('#f0fff4')
            .borderRadius(23)
            .justifyContent(FlexAlign.Center)

            Row() {
              Text("AI记账")
                .fontSize(12)
                .fontColor('#2f3747')
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
                .width(26)
                .height(26)
            }
            .width(46)
            .height(46)
            .backgroundColor('#fff0e8')
            .borderRadius(23)
            .justifyContent(FlexAlign.Center)

            Row() {
              Text("手动记账")
                .fontSize(12)
                .fontColor('#2f3747')
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
      .height(88)
      .width('100%')
      .backgroundColor('#fbfdff')
      .borderRadius(20)
      .padding({ top: 10, bottom: 10 })
      .margin({ bottom: 10 })
      .shadow({
        radius: 12,
        color: '#12000000',
        offsetY: 4
      })

      // 第二行：设置 / 数据导出/导入
      Flex({ justifyContent: FlexAlign.SpaceAround }) {
        Button({ type: ButtonType.Normal }) {
          Column() {
            Row() {
              Image($r("app.media.ic_public_budget"))
                .width(26)
                .height(26)
            }
            .width(46)
            .height(46)
            .backgroundColor('#f0f0ff')
            .borderRadius(23)
            .justifyContent(FlexAlign.Center)

            Row() {
              Text($r('app.string.settings'))
                .fontSize(12)
                .fontColor('#2f3747')
                .width('100%')
                .textAlign(TextAlign.Center)
            }.height(16).width(56)
          }.width(56).alignItems(HorizontalAlign.Center)
        }.backgroundColor(Color.Transparent).borderRadius(12).onClick(() => {
          router.pushUrl({
            url: "pages/SettingsPage"
          });
        })

        Button({ type: ButtonType.Normal }) {
          Column() {
            Row() {
              Image($r("app.media.ic_public_export"))
                .width(26)
                .height(26)
            }
            .width(46)
            .height(46)
            .backgroundColor('#fff8e1')
            .borderRadius(23)
            .justifyContent(FlexAlign.Center)

            Row() {
              Text("导出数据")
                .fontSize(12)
                .fontColor('#2f3747')
                .width('100%')
                .textAlign(TextAlign.Center)
            }.height(16).width(56)
          }.width(56).alignItems(HorizontalAlign.Center)
        }.backgroundColor(Color.Transparent).borderRadius(12).onClick(() => {
          router.pushUrl({
            url: "pages/DataExport"
          });
        })

        Button({ type: ButtonType.Normal }) {
          Column() {
            Row() {
              Image($r("app.media.ic_public_import"))
                .width(26)
                .height(26)
            }
            .width(46)
            .height(46)
            .backgroundColor('#e8f5e9')
            .borderRadius(23)
            .justifyContent(FlexAlign.Center)

            Row() {
              Text("导入数据")
                .fontSize(12)
                .fontColor('#2f3747')
                .width('100%')
                .textAlign(TextAlign.Center)
            }.height(16).width(56)
          }.width(56).alignItems(HorizontalAlign.Center)
        }.backgroundColor(Color.Transparent).borderRadius(12).onClick(() => {
          router.pushUrl({
            url: "pages/DataImport"
          });
        })
      }
      .height(88)
      .width('100%')
      .backgroundColor('#fbfdff')
      .borderRadius(20)
      .padding({ top: 10, bottom: 10 })
      .margin({ bottom: 10 })
      .shadow({
        radius: 12,
        color: '#12000000',
        offsetY: 4
      })
    }
    .padding({ left: 14, right: 14, top: 10, bottom: 8 })
  }
}