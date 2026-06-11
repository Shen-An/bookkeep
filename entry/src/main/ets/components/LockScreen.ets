// Copyright (c) 2023 Ericple
// 风风记账 is licensed under Mulan PSL v2.

import { SettingManager } from '@ohos/common';

@Component
export struct LockScreen {
  @State title: string = '';
  correctPin: string = '';
  onUnlock: () => void = () => {};
  isSetupMode: boolean = false;

  @State enteredPin: string = '';
  @State isConfirming: boolean = false;
  @State firstPin: string = '';
  @State errorMsg: string = '';

  aboutToAppear() {
    if (this.isSetupMode) {
      this.enteredPin = '';
      this.firstPin = '';
      this.isConfirming = false;
      this.errorMsg = '';
    }
  }

  build() {
    Column() {
      // 顶部标题区域
      Column() {
        Image($r("app.media.ic_public_budget"))
          .width(48)
          .height(48)
          .fillColor(Color.White)
          .opacity(0.7)
          .margin({ bottom: 12 })

        Text(this.title)
          .fontSize(20)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)

        if (this.errorMsg) {
          Text(this.errorMsg)
            .fontSize(13)
            .fontColor('#ff6b6b')
            .margin({ top: 8 })
        }
      }
      .width('100%')
      .padding({ top: 40, bottom: 24 })

      // PIN 圆点显示
      Row() {
        ForEach([0, 1, 2, 3, 4, 5], (item: number) => {
          Row()
            .width(14)
            .height(14)
            .borderRadius(7)
            .backgroundColor(this.enteredPin.length > item ? Color.White : '#55ffffff')
            .margin({ left: 6, right: 6 })
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .height(40)

      // 数字键盘
      Column() {
        Row() {
          this.createKeyButton('1')
          this.createKeyButton('2')
          this.createKeyButton('3')
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ top: 8 })

        Row() {
          this.createKeyButton('4')
          this.createKeyButton('5')
          this.createKeyButton('6')
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ top: 8 })

        Row() {
          this.createKeyButton('7')
          this.createKeyButton('8')
          this.createKeyButton('9')
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ top: 8 })

        Row() {
          Button({ type: ButtonType.Normal }) {
            Image($r("app.media.ic_public_extract_list_dark"))
              .width(28)
              .height(28)
              .fillColor(Color.White)
              .opacity(0.8)
          }
          .width(72)
          .height(72)
          .backgroundColor('#33ffffff')
          .borderRadius(36)
          .margin({ left: 12, right: 12 })
          .onClick(() => {
            if (this.enteredPin.length > 0) {
              this.enteredPin = this.enteredPin.substring(0, this.enteredPin.length - 1);
            }
          })

          this.createKeyButton('0')

          Button({ type: ButtonType.Normal }) {
            Text('✓')
              .fontSize(28)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
          }
          .width(72)
          .height(72)
          .backgroundColor(this.enteredPin.length >= 4 ? '#55ffffff' : '#22ffffff')
          .borderRadius(36)
          .margin({ left: 12, right: 12 })
          .enabled(this.enteredPin.length >= 4)
          .onClick(() => {
            this.onConfirm();
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ top: 8 })
      }
      .width('100%')
      .padding({ top: 16, bottom: 20 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#1a1a2e')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  private createKeyButton(label: string) {
    Button({ type: ButtonType.Normal }) {
      Text(label)
        .fontSize(32)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Medium)
    }
    .width(72)
    .height(72)
    .backgroundColor('#33ffffff')
    .borderRadius(36)
    .margin({ left: 12, right: 12 })
    .onClick(() => {
      if (this.enteredPin.length < 6) {
        this.enteredPin += label;
        this.errorMsg = '';
      }
    })
  }

  private onConfirm() {
    if (this.isSetupMode) {
      if (!this.isConfirming) {
        this.firstPin = this.enteredPin;
        this.enteredPin = '';
        this.isConfirming = true;
        this.title = '请再次确认 PIN 码';
        this.errorMsg = '';
      } else {
        if (this.enteredPin === this.firstPin) {
          SettingManager.getInstance().set('pin_code', this.enteredPin);
          SettingManager.getInstance().set('pin_enabled', true);
          this.onUnlock();
        } else {
          this.enteredPin = '';
          this.firstPin = '';
          this.isConfirming = false;
          this.title = '设置 PIN 码';
          this.errorMsg = '两次输入不一致，请重新设置';
        }
      }
    } else {
      if (this.enteredPin === this.correctPin) {
        this.onUnlock();
      } else {
        this.enteredPin = '';
        this.errorMsg = 'PIN 码错误';
      }
    }
  }
}