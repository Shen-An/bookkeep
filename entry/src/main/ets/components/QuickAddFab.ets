// Copyright (c) 2023 Ericple
// 风风记账 is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
// http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT, MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

import { BillingDirection, BillingInfo, DBManager, CurrencyManager } from '@ohos/common';
import promptAction from '@ohos.promptAction';
import { defaultExpenseType, defaultIncomeType, IBillType } from '../data/balanceTypes';

@Component
export struct QuickAddFab {
  onSaved?: () => void;
  @State showPanel: boolean = false;
  @State selectDir: number = 0;
  @State amountInput: string = '';
  @State selectedIdx: number = -1;
  @State isSaving: boolean = false;

  private currentTypes(): IBillType[] {
    return this.selectDir === 0 ? defaultExpenseType : defaultIncomeType;
  }

  private quickTypes(): IBillType[] {
    const all: IBillType[] = this.currentTypes();
    const count: number = all.length > 8 ? 8 : all.length;
    const result: IBillType[] = [];
    for (let i: number = 0; i < count; i++) {
      result.push(all[i]);
    }
    return result;
  }

  private saveRecord(): void {
    if (this.amountInput.length === 0 || parseFloat(this.amountInput) <= 0) {
      promptAction.showToast({ message: '请输入金额' });
      return;
    }
    if (this.selectedIdx < 0) {
      promptAction.showToast({ message: '请选择分类' });
      return;
    }

    const dir: number = this.selectDir === 0 ? BillingDirection.OUT : BillingDirection.IN;
    const typesArr: IBillType[] = this.currentTypes();
    const cat: IBillType = typesArr[this.selectedIdx];

    this.isSaving = true;
    const bill: BillingInfo = {
      type: { icon: cat.img, name: cat.title },
      amount: parseFloat(this.amountInput),
      direction: dir,
      timestamp: new Date().getTime(),
      remark: cat.title
    };

    DBManager.getInstance().addBillingInfo(bill)
      .then((result: number) => {
        this.isSaving = false;
        if (result > 0) {
          promptAction.showToast({ message: '已记录', duration: 1500 });
          this.resetPanel();
          if (this.onSaved) {
            this.onSaved();
          }
        } else {
          promptAction.showToast({ message: '保存失败' });
        }
      })
      .catch((e: Error) => {
        this.isSaving = false;
        promptAction.showToast({ message: '保存失败' });
      });
  }

  private resetPanel(): void {
    this.amountInput = '';
    this.selectedIdx = -1;
    this.showPanel = false;
  }

  build() {
    Stack() {
      // 半透明背景遮罩（面板打开时）
      if (this.showPanel) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#45000000')
          .onClick(() => {
            this.resetPanel();
          })
      }

      // Bottom Sheet 面板
      if (this.showPanel) {
        Column() {
          // 拖拽指示条
          Row()
            .width(40)
            .height(4)
            .backgroundColor('#d0d8e3')
            .borderRadius(2)
            .margin({ top: 10, bottom: 4 })

          // 标题
          Text('快速记账')
            .fontSize(18)
            .fontColor($r('app.color.text_primary'))
            .fontWeight(FontWeight.Bold)
            .margin({ top: 6, bottom: 18 })

          // 收支切换
          Row() {
            // 支出按钮
            Row() {
              Text('↓')
                .fontSize(14)
                .fontColor(this.selectDir === 0 ? Color.White : '#EF4444')
                .fontWeight(FontWeight.Bold)
                .margin({ right: 6 })
              Text('支出')
                .fontSize(14)
                .fontColor(this.selectDir === 0 ? Color.White : '#EF4444')
                .fontWeight(FontWeight.Bold)
            }
            .height(40)
            .padding({ left: 20, right: 20 })
            .backgroundColor(this.selectDir === 0 ? '#EF4444' : '#fff0f1')
            .borderRadius(20)
            .onClick(() => {
              this.selectDir = 0;
              this.selectedIdx = -1;
            })

            Blank().width(12)

            // 收入按钮
            Row() {
              Text('↑')
                .fontSize(14)
                .fontColor(this.selectDir === 1 ? Color.White : '#22C55E')
                .fontWeight(FontWeight.Bold)
                .margin({ right: 6 })
              Text('收入')
                .fontSize(14)
                .fontColor(this.selectDir === 1 ? Color.White : '#22C55E')
                .fontWeight(FontWeight.Bold)
            }
            .height(40)
            .padding({ left: 20, right: 20 })
            .backgroundColor(this.selectDir === 1 ? '#22C55E' : '#f0fff5')
            .borderRadius(20)
            .onClick(() => {
              this.selectDir = 1;
              this.selectedIdx = -1;
            })
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .margin({ bottom: 18 })

          // 金额输入
          Row() {
            Text(CurrencyManager.getInstance().getSymbol().toString())
              .fontSize(26)
              .fontColor($r('app.color.text_primary'))
              .fontWeight(FontWeight.Bold)
              .margin({ right: 8 })
            TextInput({ text: this.amountInput, placeholder: '输入金额' })
              .fontSize(26)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
              .height(48)
              .type(InputType.Number)
              .placeholderColor('#c0c8d4')
              .onChange((value: string) => {
                this.amountInput = this.cleanNumber(value);
              })
          }
          .width('100%')
          .height(56)
          .backgroundColor('#f5f7fa')
          .borderRadius(16)
          .padding({ left: 16, right: 16 })
          .margin({ bottom: 18 })

          // 分类网格
          Row() {
            Text('选择分类')
              .fontSize(14)
              .fontColor($r('app.color.text_tertiary'))
              .fontWeight(FontWeight.Medium)
          }
          .width('100%')
          .margin({ bottom: 12 })

          Grid() {
            ForEach(this.quickTypes(), (item: IBillType, idx: number) => {
              GridItem() {
                Column() {
                  Image(item.img)
                    .width(36)
                    .height(36)
                    .margin({ bottom: 6 })
                  Text(item.title)
                    .fontSize(12)
                    .fontColor(this.selectedIdx === idx ? '#3B82F6' : '#475569')
                    .fontWeight(this.selectedIdx === idx ? FontWeight.Bold : FontWeight.Normal)
                }
                .width('100%')
                .aspectRatio(1)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
                .backgroundColor(this.selectedIdx === idx ? '#EFF6FF' : '#f8f9fb')
                .border({
                  width: this.selectedIdx === idx ? 1.5 : 1,
                  color: this.selectedIdx === idx ? '#3B82F6' : '#eef0f4'
                })
                .borderRadius(16)
                .onClick(() => {
                  this.selectedIdx = idx;
                })
              }
            }, (item: IBillType, idx: number) => item.title + idx)
          }
          .columnsTemplate('1fr 1fr 1fr 1fr')
          .width('100%')
          .height(170)

          // 保存按钮
          Button({ type: ButtonType.Normal }) {
            Row() {
              if (this.isSaving) {
                LoadingProgress()
                  .width(20)
                  .height(20)
                  .color(Color.White)
                  .margin({ right: 8 })
              }
              Text(this.isSaving ? '保存中...' : '保存')
                .fontSize(17)
                .fontColor(Color.White)
                .fontWeight(FontWeight.Bold)
            }
            .justifyContent(FlexAlign.Center)
          }
          .width('100%')
          .height(52)
          .backgroundColor(this.amountInput.length > 0 && this.selectedIdx >= 0 ? '#3B82F6' : '#94A3B8')
          .borderRadius(16)
          .enabled(!this.isSaving && this.amountInput.length > 0 && this.selectedIdx >= 0)
          .onClick(() => {
            this.saveRecord();
          })
          .margin({ top: 18, bottom: 28 })
        }
        .width('100%')
        .padding({ left: 24, right: 24, top: 4, bottom: 0 })
        .backgroundColor(Color.White)
        .borderRadius({ topLeft: 28, topRight: 28 })
      }

      // 悬浮按钮
      Row() {
        Text(this.showPanel ? '✕' : '+')
          .fontSize(this.showPanel ? 20 : 32)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
      }
      .width(56)
      .height(56)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .backgroundColor('#3B82F6')
      .borderRadius(28)
      .shadow({ radius: 12, color: '#333B82F6', offsetY: 4 })
      .margin({ bottom: 24, right: 24 })
      .onClick(() => {
        this.showPanel = !this.showPanel;
        if (!this.showPanel) {
          this.resetPanel();
        }
      })
    }
    .width('100%')
    .height('100%')
    .hitTestBehavior(HitTestMode.Transparent)
    .align(Alignment.BottomEnd)
  }

  private cleanNumber(val: string): string {
    let result: string = '';
    for (let i: number = 0; i < val.length; i++) {
      const ch: string = val.charAt(i);
      if ((ch >= '0' && ch <= '9') || ch === '.') {
        result += ch;
      }
    }
    return result;
  }
}
