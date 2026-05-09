// Copyright (c) 2023 Ericple
// OpenBill is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
// http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT, MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.
import router from '@ohos.router';
import common from '@ohos.app.ability.common';
import { defaultExpenseType, defaultIncomeType, IBillType } from '../data/balanceTypes';
import { BillingDirection, DBManager } from '@ohos/common';
import promptAction from '@ohos.promptAction';
import { AiBillingParser } from '../ai/AiBillingParser';
import { TEXT_AI_CONFIG, IMAGE_AI_CONFIG } from '../ai/AiBillingConfig';
import { ImageProcessor } from '../ai/ImageProcessor';
import photoAccessHelper from '@ohos.file.photoAccessHelper';
import fs from '@ohos.file.fs';
import picker from '@ohos.file.picker';

interface AddBalanceParams {
  year?: number;
  month?: number; // 1-12
  day?: number;
  editId?: number;
  mode?: string; // 'ai' | 'manual'
}
interface IKeyboardUnit {
  content: string | Resource,
  contentType?: string,
  callback?: () => void,
  bgColor?: ResourceColor,
  foreColor?: ResourceColor
}

interface GeneratedTypeLiteralInterface_1 {
  ok: false;
  tip: string;
}

@Entry
@Component
struct AddBalance {
  @State activeTab: number = 0;
  @State activeType: Resource = $r("app.media.salaryIcon");
  @State selectedTypeName: string = '';
  @State aiInputText: string = '';
  @State aiParsing: boolean = false;
  @State imageParsing: boolean = false;
  @State balanceAmount: string = "0";
  @State balanceTempAmount: string = "0";
  @State remark: string = "";
  @State calculateAction: number = 0;
  @State doneButtonText: string = "Ok";
  @State editingId: number = -1;
  @State isEditing: boolean = false;
  @State activeYear: number = new Date().getFullYear();
  @State activeMonth: number = new Date().getMonth() + 1;
  @State activeDay: number = new Date().getDate();
  @State entryMode: string = 'ai'; // 'ai' or 'manual'
  activeDate: Date = new Date();
  context = getContext(this) as common.UIAbilityContext;
  filesDir = this.context.filesDir;

  aboutToAppear() {
    const params = router.getParams() as AddBalanceParams;
    const now = new Date();
    const editId = (params && typeof params.editId === 'number') ? params.editId : -1;

    if (editId >= 0) {
      this.entryMode = 'manual';
    } else if (params && params.mode === 'manual') {
      this.entryMode = 'manual';
    } else {
      this.entryMode = 'ai';
    }

    if (editId >= 0) {
      this.isEditing = true;
      this.editingId = editId;
      this.doneButtonText = '保存';
      // 先异步回填，日期/类型等以数据库数据为准
      DBManager.getInstance().getBillingInfoById(editId)
        .then((info) => {
          if (!info) {
            promptAction.showToast({ message: '未找到该账单' });
            return;
          }
          this.activeTab = (info.direction === BillingDirection.OUT) ? 0 : 1;
          this.activeType = info.type.icon;
          this.selectedTypeName = info.type.name;
          this.balanceAmount = info.amount.toFixed(2);
          this.balanceTempAmount = info.amount.toFixed(2);
          this.remark = info.remark ?? '';

          const d = new Date(info.timestamp);
          this.activeYear = d.getFullYear();
          this.activeMonth = d.getMonth() + 1;
          this.activeDay = d.getDate();
          this.activeDate.setTime(d.getTime());
        })
        .catch((_e: Error) => {
          promptAction.showToast({ message: '加载账单失败' });
        })
      return;
    }

    const year = (params && typeof params.year === 'number') ? params.year : now.getFullYear();
    const month = (params && typeof params.month === 'number') ? params.month : (now.getMonth() + 1);
    const day = (params && typeof params.day === 'number') ? params.day : now.getDate();
    this.activeYear = year;
    this.activeMonth = month;
    this.activeDay = day;
    this.activeDate.setFullYear(year, month - 1, day);
  }
  balanceInputUnits: IKeyboardUnit[] =
    [
      {
        content: "7",
        callback: () => {
          if (this.balanceAmount == "0") {
            this.balanceAmount = "7";
          } else {
            this.balanceAmount += "7";
          }
        }
      },
      {
        content: "8",
        callback: () => {
          if (this.balanceAmount == "0") {
            this.balanceAmount = "8";
          } else {
            this.balanceAmount += "8";
          }
        }
      },
      {
        content: "9",
        callback: () => {
          if (this.balanceAmount == "0") {
            this.balanceAmount = "9";
          } else {
            this.balanceAmount += "9";
          }
        }
      },
      {
        content: "×",
        callback: () => {
          this.calculateAction = 3;
          this.balanceTempAmount = this.balanceAmount;
          this.balanceAmount = "0";
        }
      },
      {
        content: "4",
        callback: () => {
          if (this.balanceAmount == "0") {
            this.balanceAmount = "4";
          } else {
            this.balanceAmount += "4";
          }
        }
      },
      {
        content: "5",
        callback: () => {
          if (this.balanceAmount == "0") {
            this.balanceAmount = "5";
          } else {
            this.balanceAmount += "5";
          }
        }
      },
      {
        content: "6",
        callback: () => {
          if (this.balanceAmount == "0") {
            this.balanceAmount = "6";
          } else {
            this.balanceAmount += "6";
          }
        }
      },
      {
        content: "+",
        callback: () => {
          if (this.balanceAmount.endsWith("."))
            this.balanceAmount += "0";
          this.balanceTempAmount = this.balanceAmount;
          this.balanceAmount = "0";
          this.calculateAction = 1;
          this.doneButtonText = "=";
        }
      },
      {
        content: "1",
        callback: () => {
          if (this.balanceAmount == "0") {
            this.balanceAmount = "1";
          } else {
            this.balanceAmount += "1";
          }
        }
      },
      {
        content: "2",
        callback: () => {
          if (this.balanceAmount == "0") {
            this.balanceAmount = "2";
          } else {
            this.balanceAmount += "2";
          }
        }
      },
      {
        content: "3",
        callback: () => {
          if (this.balanceAmount == "0") {
            this.balanceAmount = "3";
          } else {
            this.balanceAmount += "3";
          }
        }
      },
      {
        content: "-",
        callback: () => {
          if (this.balanceAmount.endsWith("."))
            this.balanceAmount += "0";
          this.balanceTempAmount = this.balanceAmount;
          this.balanceAmount = "0";
          this.calculateAction = 2;
          this.doneButtonText = "=";
        }
      },
      {
        content: ".",
        callback: () => {
          this.balanceAmount += "."
        }
      },
      {
        content: "0",
        callback: () => {
          if (this.balanceAmount == "0") {
            return;
          }
          this.balanceAmount += "0";
        }
      },
      {
        content: $r("app.media.delete"),
        contentType: "image",
        callback: () => {
          this.balanceAmount = this.balanceAmount.substring(0, this.balanceAmount.length - 1);
        }
      },
      {
        content: `√`,
        bgColor: $r('app.color.main_theme_blue'),
        foreColor: Color.White,
        callback: () => {
          if (this.balanceTempAmount != "0") {
            if (this.calculateAction == 1) {
              this.balanceAmount = (parseFloat(this.balanceTempAmount) + parseFloat(this.balanceAmount)).toFixed(2);
            } else if (this.calculateAction == 2) {
              this.balanceAmount = (parseFloat(this.balanceTempAmount) - parseFloat(this.balanceAmount)).toFixed(2);
            } else if (this.calculateAction == 3) {
              this.balanceAmount = (parseFloat(this.balanceTempAmount) * parseFloat(this.balanceAmount)).toFixed(2);
            }
            this.calculateAction = 0;
            this.balanceTempAmount = "0";
            this.doneButtonText = "Ok";
            return;
          }
          if (this.balanceAmount == "0")
            return;
          if (this.remark == "")
            return;
          if (this.balanceAmount.endsWith('.')) {
            this.balanceAmount += '0';
          }
          const amount = parseFloat(this.balanceAmount);
          if (Number.isNaN(amount)) {
            promptAction.showToast({ message: '金额格式不正确' });
            return;
          }

          // Persist with a time component so it always falls into the chosen day bucket.
          const now = new Date();
          const ts = new Date(this.activeDate.getTime());
          ts.setHours(now.getHours(), now.getMinutes(), now.getSeconds(), now.getMilliseconds());

          if (this.isEditing) {
            DBManager.getInstance().updateBillingInfo({
              id: this.editingId,
              type: {
                icon: this.activeType,
                name: this.selectedTypeName
              },
              amount,
              direction: this.activeTab == 0 ? BillingDirection.OUT : BillingDirection.IN,
              timestamp: ts.getTime(),
              remark: this.remark
            })
              .then((affected: number) => {
                if (affected === -2) {
                  promptAction.showToast({ message: '保存失败（数据库未就绪）' });
                  return;
                }
                if (affected > 0) {
                  router.back();
                } else {
                  promptAction.showToast({ message: '保存失败（未更新任何记录）' });
                }
              })
              .catch((_e: Error) => {
                promptAction.showToast({ message: '保存失败（数据库未就绪）' });
              })
          } else {
            DBManager.getInstance().addBillingInfo({
              type: {
                icon: this.activeType,
                name: this.selectedTypeName
              },
              amount,
              direction: this.activeTab == 0 ? BillingDirection.OUT : BillingDirection.IN,
              timestamp: ts.getTime(),
              remark: this.remark
            })
              .then((v: number) => {
                if (v === -2) {
                  promptAction.showToast({ message: '保存失败（数据库未就绪）' });
                  return;
                }
                if (v !== -1) {
                  router.back();
                } else {
                  promptAction.showToast({ message: '保存失败（数据库写入异常）' });
                }
              })
              .catch((_e: Error) => {
                promptAction.showToast({ message: '保存失败（数据库未就绪）' });
              })
          }
        }
      }
    ];
  @State inputMarginTop: number = 1000;
  @State inputOpacity: number = 0;

  onBackPress() {
    if (this.selectedTypeName != '') {
      this.selectedTypeName = '';
      return;
    }
  }


  async selectImageFromGallery() {
    try {
      const photoPicker = new picker.PhotoViewPicker();
      const result = await photoPicker.select({
        maxSelectNumber: 1,
        MIMEType: picker.PhotoViewMIMETypes.IMAGE_TYPE
      });
      if (result && result.photoUris && result.photoUris.length > 0) {
        const imageUri = result.photoUris[0];
        await this.recognizeImage(imageUri);
      }
    } catch (error) {
      console.error('选择图片失败:', error);
      promptAction.showToast({ message: '选择图片失败' });
    }
  }

  async recognizeImage(imageUri: string) {
    if (this.imageParsing) {
      return;
    }

    this.imageParsing = true;
    try {
      const expenseCategories = defaultExpenseType.map(t => t.title);
      const incomeCategories = defaultIncomeType.map(t => t.title);
      
      const result = await ImageProcessor.recognizeImageText(imageUri, IMAGE_AI_CONFIG, expenseCategories, incomeCategories);
      if (result) {
        const parsed = ImageProcessor.parseAiResponse(result);

        if (parsed.amount) {
          this.balanceAmount = parsed.amount.toFixed(2);
          this.balanceTempAmount = parsed.amount.toFixed(2);
        }

        if (parsed.direction) {
          this.activeTab = parsed.direction === 'IN' ? 1 : 0;
        }

        if (parsed.category) {
          const types = this.activeTab === 0 ? defaultExpenseType : defaultIncomeType;
          const foundType = types.find(t => t.title === parsed.category);
          if (foundType) {
            this.activeType = foundType.img;
            this.selectedTypeName = foundType.title;
          }
        }

        if (parsed.date) {
          const date = new Date(parsed.date);
          if (!isNaN(date.getTime())) {
            this.activeYear = date.getFullYear();
            this.activeMonth = date.getMonth() + 1;
            this.activeDay = date.getDate();
            this.activeDate.setTime(date.getTime());
          }
        }

        if (parsed.remark) {
          this.remark = parsed.remark;
        }

        animateTo({ duration: 300, curve: Curve.EaseOut }, () => {
          this.inputMarginTop = 0;
          this.inputOpacity = 1;
        });

        promptAction.showToast({ message: '图片识别成功' });
      } else {
        promptAction.showToast({ message: '图片识别失败，请重试' });
      }
    } catch (error) {
      console.error('图片识别失败:', error);
      promptAction.showToast({ message: '图片识别失败，请重试' });
    } finally {
      this.imageParsing = false;
    }
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        // 顶部导航栏 - 渐变背景
        Row() {
          Row() {
            Text($r("app.string.balance"))
              .fontSize(17)
              .fontColor(Color.White)
              .fontWeight(this.activeTab == 0 ? FontWeight.Bold : FontWeight.Normal)
              .onClick(() => {
                this.activeTab = 0;
                this.selectedTypeName = '';
                this.balanceAmount = "0";
              })
              .border({
                width: {
                  bottom: this.activeTab == 0 ? 2 : 0
                },
                color: Color.White
              })
              .padding({ bottom: 12 })
              .margin({ top: 12, right: 20, left: 20 })
            Text($r("app.string.income"))
              .fontSize(17)
              .fontColor(Color.White)
              .fontWeight(this.activeTab == 1 ? FontWeight.Bold : FontWeight.Normal)
              .onClick(() => {
                this.activeTab = 1;
                this.selectedTypeName = '';
                this.balanceAmount = "0";
              })
              .border({
                width: {
                  bottom: this.activeTab == 1 ? 2 : 0
                },
                color: Color.White
              })
              .padding({ bottom: 12 })
              .margin({ top: 12, right: 20, left: 20 })
          }

          Text($r("app.string.cancel"))
            .fontSize(16)
          .fontColor('#ffffffe6')
            .onClick(() => {
              router.back()
            })
            .textAlign(TextAlign.End)
            .margin({ right: 24 })
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .height(52)
        .width('100%')
        .linearGradient({
          angle: 180,
          colors: [
            [$r('app.color.main_theme_gradient_start'), 0],
            [$r('app.color.main_theme_gradient_end'), 1]
          ]
        })

        // AI one-sentence billing - only show in AI mode
        if (this.entryMode === 'ai') {
          Column({ space: 10 }) {
            Row({ space: 8 }) {
              TextInput({
                text: this.aiInputText,
                placeholder: $r('app.string.ai_billing_placeholder')
              })
                .layoutWeight(1)
                .borderRadius(12)
              .backgroundColor(Color.White)
                .padding({ left: 12 })
                .fontColor('#333333')
                .placeholderColor($r('app.color.text_gray'))
                .onChange((v: string) => {
                  this.aiInputText = v;
                })

              Button({ type: ButtonType.Normal }) {
                Text(this.aiParsing ? $r('app.string.ai_billing_parsing') : $r('app.string.ai_billing_parse'))
                  .fontSize(14)
                  .fontColor($r('app.color.main_theme_blue'))
                  .fontWeight(FontWeight.Medium)
              }
              .backgroundColor(Color.White)
              .borderRadius(12)
              .enabled(!this.aiParsing)
              .onClick(async () => {
                if (this.aiParsing) {
                  return;
                }
                const input = (this.aiInputText ?? '').trim();
                if (!input) {
                  promptAction.showToast({ message: '请输入一句话，例如：今天午饭25 / 发工资5000 / 昨晚打车32' });
                  return;
                }
                this.aiParsing = true;
                try {
                  if (!TEXT_AI_CONFIG.baseUrl || !TEXT_AI_CONFIG.apiKey) {
                    promptAction.showToast({ message: '未配置 AI 服务，将先使用本地规则解析（可在 ai/AiBillingConfig.ts 填写 baseUrl/apiKey）。' });
                  }
                  const ret = await AiBillingParser.parseToBill(input, {
                    expenseTypes: defaultExpenseType,
                    incomeTypes: defaultIncomeType,
                    preferLLM: true
                  });
                  if (!ret.ok) {
                    const tip = (ret as GeneratedTypeLiteralInterface_1).tip;
                    promptAction.showToast({ message: tip });
                    return;
                  }

                  const bill = ret.bill;
                  this.activeTab = bill.direction === BillingDirection.OUT ? 0 : 1;
                  this.activeType = bill.type.icon;
                  this.selectedTypeName = bill.type.name;
                  this.balanceAmount = bill.amount.toFixed(2);
                  this.balanceTempAmount = bill.amount.toFixed(2);
                  this.remark = bill.remark ?? '';

                  const d = new Date(bill.timestamp);
                  this.activeYear = d.getFullYear();
                  this.activeMonth = d.getMonth() + 1;
                  this.activeDay = d.getDate();
                  this.activeDate.setTime(d.getTime());

                  animateTo({ duration: 300, curve: Curve.EaseOut }, () => {
                    this.inputMarginTop = 0;
                    this.inputOpacity = 1;
                  })

                  promptAction.showToast({ message: `已识别：${ret.summary}` });
                } finally {
                  this.aiParsing = false;
                }
              })
            }

            Row({ space: 8 }) {
              TextInput({
                placeholder: $r('app.string.ai_image_upload_hint')
              })
                .layoutWeight(1)
                .borderRadius(12)
                .backgroundColor(Color.White)
                .padding({ left: 12 })
                .placeholderColor($r('app.color.text_gray'))

              Button({ type: ButtonType.Normal }) {
                Text(this.imageParsing ? $r('app.string.ai_image_parsing') : $r('app.string.ai_image_recognize'))
                  .fontSize(14)
                  .fontColor($r('app.color.main_theme_blue'))
                  .fontWeight(FontWeight.Medium)
              }
              .backgroundColor(Color.White)
              .borderRadius(12)
              .enabled(!this.imageParsing)
              .onClick(() => {
                this.selectImageFromGallery();
              })
            }
          }
          .padding({ left: 16, right: 16, top: 12, bottom: 12 })
          .backgroundColor($r('app.color.main_theme_gradient_start'))
        }

        // 分类选择网格
        Scroll() {
          GridRow({ columns: 4, gutter: 16 }) {
            ForEach(this.activeTab == 0 ? defaultExpenseType : defaultIncomeType, (item: IBillType) => {
              GridCol() {
                Column({ space: 6 }) {
                  Row() {
                    Image(item.img)
                      .width(28)
                      .height(28)
                  }
                  .shadow({
                    radius: this.selectedTypeName == item.title ? 8 : 4,
                    color: '#1a000000',
                    offsetY: 2
                  })
                  .borderRadius(16)
                  .backgroundColor(this.selectedTypeName == item.title ? "#ffd0ebff" : Color.White)
                  .width(52)
                  .height(52)
                  .justifyContent(FlexAlign.Center)
                  .onClick(() => {
                    this.selectedTypeName = item.title;
                    this.activeType = item.img;
                    animateTo({ duration: 800, curve: Curve.EaseOut }, () => {
                      this.inputMarginTop = 0;
                      this.inputOpacity = 1;
                    })
                  })

                  Row() {
                    Text(item.title)
                      .fontSize(12)
                      .fontColor(this.selectedTypeName == item.title ? $r('app.color.main_theme_blue') : '#666666')
                      .fontWeight(this.selectedTypeName == item.title ? FontWeight.Medium : FontWeight.Normal)
                  }
                }
                .width(60)
                .height(80)
              }
            })
          }
          .padding({ left: 16, right: 16, top: 16, bottom: 16 })
        }
        .layoutWeight(1)
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.page_background'))

      // 底部输入面板
      Column() {
        // 金额显示
        Row() {
          Text(`¥ ${this.balanceAmount}`)
            .textAlign(TextAlign.End)
            .width('100%')
            .padding({ left: 16, right: 16 })
            .fontSize(32)
            .fontColor('#1a1a1a')
            .fontWeight(FontWeight.Bold)
        }
        .height(48)
        .backgroundColor('#f8f9fa')

        // 备注输入
        Row() {
          TextInput({
            text: this.remark,
            placeholder: $r("app.string.add_balance_remark_placeholder")
          })
          .borderRadius(10)
          .margin({ left: 12, right: 12, top: 8, bottom: 4 })
          .backgroundColor('#f0f0f0')
          .padding({ left: 12 })
          .placeholderColor($r('app.color.text_gray'))
          .fontColor('#333333')
          .height(40)
          .onChange(value => {
            this.remark = value;
          })
        }
        .backgroundColor(Color.White)

        // 日期选择
        Row() {
          Image($r("app.media.ic_public_extract_list_dark"))
            .width(14)
            .height(14)
            .margin({ right: 6 })
          Text(`${this.activeYear} / ${(this.activeMonth).toString()
            .padStart(2, '0')} / ${this.activeDay.toString().padStart(2, '0')}`)
            .fontSize(15)
            .fontColor('#666666')
            .margin({ bottom: 8 })
            .onClick(() => {
            DatePickerDialog.show({
              start: new Date("2000-01-01"),
              onAccept: (v) => {
                const pickedYear = (typeof v.year === 'number') ? v.year : this.activeYear;
                const pickedMonth0 = (typeof v.month === 'number') ? v.month : (this.activeMonth - 1);
                const pickedDay = (typeof v.day === 'number') ? v.day : this.activeDay;

                this.activeYear = pickedYear;
                this.activeMonth = pickedMonth0 + 1;
                this.activeDay = pickedDay;

                this.activeDate.setFullYear(pickedYear, pickedMonth0, pickedDay);
              },
              selected: this.activeDate
            })
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Color.White)

        // 数字键盘
        GridRow({ columns: 4, gutter: 0 }) {
          ForEach(this.balanceInputUnits, (unit: IKeyboardUnit) => {
            GridCol() {
              Button({ type: ButtonType.Normal }) {
                if (unit.contentType == "image") {
                  Image(unit.content).width(22)
                } else {
                  Text(unit.content)
                    .fontSize(22)
                    .fontColor(unit.foreColor ?? "#1a1a1a")
                    .fontWeight(FontWeight.Medium)
                }
              }
              .height(52)
              .backgroundColor(unit.bgColor ?? Color.White)
              .width('100%')
              .borderRadius(0)
              .onClick(() => {
                if (unit.callback) {
                  unit.callback();
                }
              })
            }
            .border({
              width: {
                top: 0.5,
                right: 0.5,
                bottom: 0,
                left: 0
              },
              color: '#fff0f0f0'
            })
          })
        }
      }
      .width('100%')
      .shadow({
        radius: 16,
        offsetY: -4,
        color: '#1a000000'
      })
      .margin({ top: this.inputMarginTop })
      .opacity(this.inputOpacity)
      .backgroundColor(Color.White)
    }
    .width('100%')
    .height('100%')
  }
}