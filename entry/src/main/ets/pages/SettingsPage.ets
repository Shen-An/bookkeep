// Copyright (c) 2023 Ericple
// 风风记账 is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
// http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT, MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.
import router from '@ohos.router';
import { DBManager, Logger, SettingManager, CurrencyManager } from '@ohos/common';
import { BusinessError } from '@ohos.base';

let TAG = "SettingsPage";

@Entry
@Component
struct SettingsPage {
  @State currencyUnit: string = '¥';
  @State billingCount: number = 0;

  aboutToAppear() {
    this.loadBillingCount();
    this.loadCurrencyUnit();
  }

  private loadCurrencyUnit() {
    SettingManager.getInstance().get<string>('currency_unit', '¥').then((v: string) => {
      this.currencyUnit = v;
    }).catch(() => {});
  }

  private loadBillingCount() {
    DBManager.getInstance().getBillingCount()
      .then((count: number) => {
        this.billingCount = count;
      })
      .catch(() => {
        this.billingCount = 0;
      })
  }

  private handleCurrencyPicker() {
    const currencies: string[] = CurrencyManager.getCurrencies();
    let selectedIdx = 0;
    for (let i = 0; i < currencies.length; i++) {
      if (currencies[i] == this.currencyUnit) {
        selectedIdx = i;
        break;
      }
    }
    TextPickerDialog.show({
      range: CurrencyManager.getCurrencies(),
      selected: selectedIdx,
      onAccept: (value) => {
        if (value) {
          const selected = value.value;
          if (typeof selected === 'string') {
            this.currencyUnit = selected;
            SettingManager.getInstance().set('currency_unit', selected);
            CurrencyManager.getInstance().setSymbol(selected);
          }
        }
      }
    })
  }

  private handleClearData() {
    AlertDialog.show({
      title: $r('app.string.settings_clear_data'),
      message: $r('app.string.settings_clear_confirm'),
      autoCancel: true,
      alignment: DialogAlignment.Center,
      primaryButton: {
        value: $r('app.string.cancel'),
        action: () => {}
      },
      secondaryButton: {
        value: $r('app.string.data_import_start'),
        fontColor: '#ff0000',
        action: () => {
          DBManager.getInstance().deleteAllBillingInfo()
            .then((affected: number) => {
              if (affected >= 0) {
                this.billingCount = 0;
                AlertDialog.show({
                  title: $r('app.string.settings_cleared'),
                  message: '',
                  autoCancel: true,
                  alignment: DialogAlignment.Center
                });
              }
            })
            .catch((e: BusinessError) => {
              Logger.err(TAG, 'clear data failed', e);
            })
        }
      }
    })
  }

  build() {
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
          Text($r('app.string.settings'))
            .fontColor(Color.White)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
          Text('偏好、数据与应用信息')
            .fontSize(12)
            .fontColor('#d8efff')
            .margin({ top: 3 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        .margin({ left: 12 })
      }
      .width('100%')
      .padding({ left: 18, right: 18, top: 28, bottom: 20 })
      .linearGradient({
        angle: 145,
        colors: [
          ['#FF2CC4E1', 0],
          [$r('app.color.main_theme_gradient_start'), 0.5],
          [$r('app.color.main_theme_gradient_end'), 1]
        ]
      })

      Scroll() {
        Column() {
          Row() {
            Column() {
              Text('账本数据')
                .fontSize(13)
                .fontColor('#d7edff')
              Text(`${this.billingCount}`)
                .fontSize(38)
                .fontColor(Color.White)
                .fontWeight(FontWeight.Bold)
                .margin({ top: 6 })
              Text('条记录正在被管理')
                .fontSize(12)
                .fontColor('#d7edff')
                .margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            Column() {
              Text('当前货币')
                .fontSize(12)
                .fontColor('#6a7c94')
              Text(this.currencyUnit)
                .fontSize(30)
                .fontColor('#126dff')
                .fontWeight(FontWeight.Bold)
                .margin({ top: 5 })
            }
            .alignItems(HorizontalAlign.Center)
            .justifyContent(FlexAlign.Center)
            .width(96)
            .height(96)
            .backgroundColor(Color.White)
            .borderRadius(28)
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

          Column() {
            Text('常用设置')
              .fontSize(20)
              .fontColor('#1f2a3d')
              .fontWeight(FontWeight.Bold)
              .width('100%')

            Row() {
              Column() {
                Text('货币单位')
                  .fontSize(16)
                  .fontColor('#1f2a3d')
                  .fontWeight(FontWeight.Bold)
                Text('切换全局金额展示符号')
                  .fontSize(12)
                  .fontColor('#8b96a8')
                  .margin({ top: 5 })
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
              Text(this.currencyUnit)
                .fontSize(22)
                .fontColor('#126dff')
                .fontWeight(FontWeight.Bold)
                .margin({ right: 12 })
              Text('›')
                .fontSize(22)
                .fontColor('#b7c0ce')
            }
            .width('100%')
            .padding(18)
            .backgroundColor('#f5f9ff')
            .borderRadius(22)
            .margin({ top: 14 })
            .onClick(() => this.handleCurrencyPicker())

            Row() {
              Column() {
                Text('AI 配置')
                  .fontSize(16)
                  .fontColor('#1f2a3d')
                  .fontWeight(FontWeight.Bold)
                Text('配置智能记账能力')
                  .fontSize(12)
                  .fontColor('#8b96a8')
                  .margin({ top: 5 })
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
              Image($r("app.media.ic_public_billing_graphic"))
                .width(26)
                .height(26)
              Text('›')
                .fontSize(22)
                .fontColor('#b7c0ce')
                .margin({ left: 10 })
            }
            .width('100%')
            .padding(18)
            .backgroundColor('#f3f8ff')
            .borderRadius(22)
            .margin({ top: 12 })
            .onClick(() => {
              router.pushUrl({ url: 'ai/AiBillingSettings' });
            })
          }
          .width('100%')
          .padding(20)
          .backgroundColor(Color.White)
          .borderRadius(28)
          .margin({ top: 18 })
          .shadow({ radius: 16, color: '#12000000', offsetY: 7 })

          Column() {
            Text('数据管理')
              .fontSize(20)
              .fontColor('#1f2a3d')
              .fontWeight(FontWeight.Bold)
              .width('100%')

            Row() {
              Column() {
                Text($r('app.string.settings_clear_data'))
                  .fontSize(16)
                  .fontColor('#ff4757')
                  .fontWeight(FontWeight.Bold)
                Text(`当前 ${this.billingCount} 条记录，清除后不可恢复`)
                  .fontSize(12)
                  .fontColor('#8b96a8')
                  .margin({ top: 5 })
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
              Image($r("app.media.delete"))
                .width(28)
                .height(28)
            }
            .width('100%')
            .padding(18)
            .backgroundColor('#fff4f5')
            .borderRadius(22)
            .margin({ top: 14 })
            .onClick(() => this.handleClearData())
          }
          .width('100%')
          .padding(20)
          .backgroundColor(Color.White)
          .borderRadius(28)
          .margin({ top: 18 })
          .shadow({ radius: 16, color: '#12000000', offsetY: 7 })

          Column() {
            Text('关于应用')
              .fontSize(20)
              .fontColor('#1f2a3d')
              .fontWeight(FontWeight.Bold)
              .width('100%')

            Row() {
              Image($r("app.media.ic_public_opensource_info"))
                .width(28)
                .height(28)
                .margin({ right: 12 })
              Text($r('app.string.settings_about'))
                .fontSize(16)
                .fontColor('#1f2a3d')
                .fontWeight(FontWeight.Bold)
              Blank()
              Text('›')
                .fontSize(22)
                .fontColor('#b7c0ce')
            }
            .width('100%')
            .padding({ top: 18, bottom: 18 })
            .onClick(() => {
              router.pushUrl({ url: 'pages/Copyright' })
            })

            Divider().color('#eef2f7')

            Row() {
              Image($r("app.media.icon"))
                .width(28)
                .height(28)
                .borderRadius(14)
                .margin({ right: 12 })
              Text($r('app.string.settings_version'))
                .fontSize(16)
                .fontColor('#1f2a3d')
                .fontWeight(FontWeight.Bold)
              Blank()
              Text('v1.0.0')
                .fontSize(14)
                .fontColor('#8b96a8')
            }
            .width('100%')
            .padding({ top: 18, bottom: 18 })
          }
          .width('100%')
          .padding(20)
          .backgroundColor(Color.White)
          .borderRadius(28)
          .margin({ top: 18, bottom: 28 })
          .shadow({ radius: 16, color: '#12000000', offsetY: 7 })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16 })
      }
      .layoutWeight(1)
      .width('100%')
    }
    .height('100%')
    .width('100%')
    .backgroundColor('#f3f7fb')
  }
}
