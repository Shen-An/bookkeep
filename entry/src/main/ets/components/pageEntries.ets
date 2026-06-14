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
      Row() {
        Text('快速开始')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
        Blank()
        Text('记一笔更轻松')
          .fontSize(12)
          .fontColor($r('app.color.text_tertiary'))
      }
      .width('100%')
      .margin({ bottom: 12 })

      Row() {
        Button({ type: ButtonType.Normal }) {
          Column() {
            Row() {
              Image($r("app.media.ic_public_add_billing"))
                .width(30)
                .height(30)
              Blank()
              Text('AI')
                .fontSize(13)
                .fontColor('#ffffffcc')
                .fontWeight(FontWeight.Bold)
            }
            .width('100%')

            Text('AI 记账')
              .fontSize(18)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
              .width('100%')
              .margin({ top: 18 })
            Text('拍照或文字智能识别')
              .fontSize(12)
              .fontColor('#ffffffcc')
              .width('100%')
              .margin({ top: 4 })
          }
          .alignItems(HorizontalAlign.Start)
        }
        .layoutWeight(1)
        .height(120)
        .padding(18)
        .backgroundColor('#3B82F6')
        .borderRadius(24)
        .shadow({ radius: 18, color: '#333B82F6', offsetY: 8 })
        .onClick(() => {
          router.pushUrl({
            url: "pages/addBalance",
            params: {
              year: this.selectedDate.getFullYear(),
              month: this.selectedDate.getMonth() + 1,
              day: this.selectedDate.getDate(),
              mode: 'ai'
            }
          })
        })

        Button({ type: ButtonType.Normal }) {
          Column() {
            Row() {
              Image($r("app.media.icon"))
                .width(30)
                .height(30)
              Blank()
              Text('+')
                .fontSize(20)
                .fontColor($r('app.color.text_primary'))
                .fontWeight(FontWeight.Bold)
            }
            .width('100%')

            Text('手动记账')
              .fontSize(18)
              .fontColor($r('app.color.text_primary'))
              .fontWeight(FontWeight.Bold)
              .width('100%')
              .margin({ top: 18 })
            Text('快速录入金额分类')
              .fontSize(12)
              .fontColor($r('app.color.text_secondary'))
              .width('100%')
              .margin({ top: 4 })
          }
          .alignItems(HorizontalAlign.Start)
        }
        .layoutWeight(1)
        .height(120)
        .padding(18)
        .backgroundColor('#fff5ea')
        .borderRadius(24)
        .shadow({ radius: 16, color: '#18ff922b', offsetY: 7 })
        .margin({ left: 12 })
        .onClick(() => {
          router.pushUrl({
            url: "pages/addBalance",
            params: {
              year: this.selectedDate.getFullYear(),
              month: this.selectedDate.getMonth() + 1,
              day: this.selectedDate.getDate(),
              mode: 'manual'
            }
          })
        })
      }
      .width('100%')

      Row() {
        Button({ type: ButtonType.Normal }) {
          Column() {
            Image($r("app.media.ic_public_budget"))
              .width(24)
              .height(24)
            Text('年度账单')
              .fontSize(12)
              .fontColor($r('app.color.text_primary'))
              .fontWeight(FontWeight.Medium)
              .margin({ top: 8 })
          }
        }
        .layoutWeight(1)
        .height(82)
        .backgroundColor('#f0f7ff')
        .borderRadius(20)
        .onClick(() => {
          router.pushUrl({ url: "pages/BillInfoPage", params: { date: this.selectedDate } });
        })

        Button({ type: ButtonType.Normal }) {
          Column() {
            Image($r("app.media.ic_public_billing_graphic"))
              .width(24)
              .height(24)
            Text('经济图表')
              .fontSize(12)
              .fontColor($r('app.color.text_primary'))
              .fontWeight(FontWeight.Medium)
              .margin({ top: 8 })
          }
        }
        .layoutWeight(1)
        .height(82)
        .backgroundColor('#f4f0ff')
        .borderRadius(20)
        .margin({ left: 10 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/EconomicCharts', params: { date: this.selectedDate } })
        })

        Button({ type: ButtonType.Normal }) {
          Column() {
            Image($r("app.media.ic_public_budget"))
              .width(24)
              .height(24)
            Text($r('app.string.settings'))
              .fontSize(12)
              .fontColor($r('app.color.text_primary'))
              .fontWeight(FontWeight.Medium)
              .margin({ top: 8 })
          }
        }
        .layoutWeight(1)
        .height(82)
        .backgroundColor('#eef5ff')
        .borderRadius(20)
        .margin({ left: 10 })
        .onClick(() => {
          router.pushUrl({ url: "pages/SettingsPage" });
        })
      }
      .width('100%')
      .margin({ top: 14 })

      Row() {
        Button({ type: ButtonType.Normal }) {
          Row() {
            Image($r("app.media.ic_public_import"))
              .width(20)
              .height(20)
              .margin({ right: 8 })
            Text('导入')
              .fontSize(13)
              .fontColor($r('app.color.text_secondary'))
              .fontWeight(FontWeight.Medium)
          }
          .justifyContent(FlexAlign.Center)
        }
        .layoutWeight(1)
        .height(48)
        .backgroundColor('#f4faf3')
        .borderRadius(18)
        .onClick(() => {
          router.pushUrl({ url: "pages/DataImport" });
        })

        Button({ type: ButtonType.Normal }) {
          Row() {
            Image($r("app.media.ic_public_export"))
              .width(20)
              .height(20)
              .margin({ right: 8 })
            Text('导出')
              .fontSize(13)
              .fontColor($r('app.color.text_secondary'))
              .fontWeight(FontWeight.Medium)
          }
          .justifyContent(FlexAlign.Center)
        }
        .layoutWeight(1)
        .height(48)
        .backgroundColor('#fff8e1')
        .borderRadius(18)
        .margin({ left: 10 })
        .onClick(() => {
          router.pushUrl({ url: "pages/DataExport" });
        })

        Button({ type: ButtonType.Normal }) {
          Row() {
            Image($r("app.media.ic_public_opensource_info"))
              .width(20)
              .height(20)
              .margin({ right: 8 })
            Text('关于')
              .fontSize(13)
              .fontColor($r('app.color.text_secondary'))
              .fontWeight(FontWeight.Medium)
          }
          .justifyContent(FlexAlign.Center)
        }
        .layoutWeight(1)
        .height(48)
        .backgroundColor('#fff0f0')
        .borderRadius(18)
        .margin({ left: 10 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/Copyright' }, router.RouterMode.Standard, err => { return; })
        })
      }
      .width('100%')
      .margin({ top: 10 })
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 18, bottom: 16 })
    .backgroundColor(Color.White)
    .borderRadius(28)
    .margin({ left: 14, right: 14, top: -10, bottom: 10 })
    .shadow({ radius: 16, color: '#16000000', offsetY: 6 })
  }
}
