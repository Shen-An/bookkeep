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

  private handleClearData() {
    AlertDialog.show({
      title: $r('app.string.settings_clear_data'),
      message: $r('app.string.settings_clear_confirm'),
      autoCancel: true,
      alignment: DialogAlignment.Center,
      primaryButton: {
        value: $r('app.string.cancel'),
        action: () => {
          // do nothing
        }
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
      // 顶部标题栏
      Row() {
        Button({ type: ButtonType.Normal }) {
          Text('←')
            .fontSize(22)
            .fontColor(Color.White)
        }
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          router.back();
        })

        Text($r('app.string.settings'))
          .fontColor(Color.White)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .layoutWeight(1)
          .margin({ right: 40 })
      }
      .padding({ top: 28, bottom: 16, left: 8, right: 8 })
      .width('100%')
      .linearGradient({
        angle: 180,
        colors: [
          [$r('app.color.main_theme_gradient_start'), 0],
          [$r('app.color.main_theme_gradient_end'), 1]
        ]
      })

      // 设置内容
      Scroll() {
        Column() {
          // 通用设置
          Column() {
            Row() {
              Text($r('app.string.settings_general'))
                .fontSize(13)
                .fontColor('#7b8798')
                .fontWeight(FontWeight.Medium)
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 16, bottom: 8 })

            Column() {
              // 货币单位
              Row() {
                Text($r('app.string.settings_currency_unit'))
                  .fontSize(15)
                  .fontColor('#202938')

                Blank()

                Text(this.currencyUnit)
                  .fontSize(15)
                  .fontColor('#7b8798')
                  .margin({ right: 8 })

                Text('›')
                  .fontSize(18)
                  .fontColor('#cccccc')
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 16, bottom: 16 })
              .backgroundColor('#fbfdff')
              .borderRadius({ topLeft: 12, topRight: 12, bottomLeft: 12, bottomRight: 12 })
              .onClick(() => {
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
                        // Directly set symbol (avoids race with async Prefs flush)
                        CurrencyManager.getInstance().setSymbol(selected);
                      }
                    }
                  }
                })
              })
            }
            .width('100%')
            .padding({ left: 12, right: 12 })
          }

          // AI 配置
          Column() {
            Row() {
              Text($r('app.string.settings_ai_config'))
                .fontSize(13)
                .fontColor('#7b8798')
                .fontWeight(FontWeight.Medium)
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 20, bottom: 8 })

            Column() {
              Row() {
                Image($r("app.media.ic_public_billing_graphic"))
                  .width(24)
                  .height(24)
                  .margin({ right: 12 })

                Text($r('app.string.settings_ai_config'))
                  .fontSize(15)
                  .fontColor('#202938')

                Blank()

                Text('›')
                  .fontSize(18)
                  .fontColor('#cccccc')
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 16, bottom: 16 })
              .backgroundColor('#fbfdff')
              .borderRadius({ topLeft: 12, topRight: 12, bottomLeft: 12, bottomRight: 12 })
              .onClick(() => {
                router.pushUrl({
                  url: 'ai/AiBillingSettings'
                });
              })
            }
            .width('100%')
            .padding({ left: 12, right: 12 })
          }

          // 数据管理
          Column() {
            Row() {
              Text($r('app.string.settings_data_management'))
                .fontSize(13)
                .fontColor('#7b8798')
                .fontWeight(FontWeight.Medium)
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 20, bottom: 8 })

            Column() {
              Row() {
                Image($r("app.media.delete"))
                  .width(24)
                  .height(24)
                  .margin({ right: 12 })

                Column() {
                  Text($r('app.string.settings_clear_data'))
                    .fontSize(15)
                    .fontColor('#ff4444')

                  Text(`当前 ${this.billingCount} 条记录`)
                    .fontSize(12)
                    .fontColor('#7b8798')
                    .margin({ top: 2 })
                }
                .alignItems(HorizontalAlign.Start)

                Blank()

                Text('›')
                  .fontSize(18)
                  .fontColor('#cccccc')
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 16, bottom: 16 })
              .backgroundColor('#fbfdff')
              .borderRadius({ topLeft: 12, topRight: 12, bottomLeft: 12, bottomRight: 12 })
              .onClick(() => {
                this.handleClearData();
              })
            }
            .width('100%')
            .padding({ left: 12, right: 12 })
          }

          // 关于
          Column() {
            Row() {
              Text($r('app.string.settings_about'))
                .fontSize(13)
                .fontColor('#7b8798')
                .fontWeight(FontWeight.Medium)
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 20, bottom: 8 })

            Column() {
              Row() {
                Image($r("app.media.ic_public_opensource_info"))
                  .width(24)
                  .height(24)
                  .margin({ right: 12 })

                Text($r('app.string.settings_about'))
                  .fontSize(15)
                  .fontColor('#202938')

                Blank()

                Text('›')
                  .fontSize(18)
                  .fontColor('#cccccc')
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 16, bottom: 16 })
              .backgroundColor('#fbfdff')
              .borderRadius({ topLeft: 12, topRight: 12 })
              .onClick(() => {
                router.pushUrl({
                  url: 'pages/Copyright'
                })
              })

              // 版本信息
              Row() {
                Image($r("app.media.icon"))
                  .width(24)
                  .height(24)
                  .margin({ right: 12 })
                  .borderRadius(12)

                Text($r('app.string.settings_version'))
                  .fontSize(15)
                  .fontColor('#202938')

                Blank()

                Text('v1.0.0')
                  .fontSize(14)
                  .fontColor('#7b8798')
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 16, bottom: 16 })
              .backgroundColor('#fbfdff')
              .borderRadius({ bottomLeft: 12, bottomRight: 12 })
            }
            .width('100%')
            .padding({ left: 12, right: 12 })
          }
        }
        .width('100%')
        .padding({ bottom: 32 })
      }
      .layoutWeight(1)
      .width('100%')
    }
    .height('100%')
    .width('100%')
    .backgroundColor($r('app.color.page_background'))
  }
}