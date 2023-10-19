// Copyright (c) 2023 Ericple
// OpenBill is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
// http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT, MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.
import router from '@ohos.router';
import common from '@ohos.app.ability.common';
import { defaultExpenseType, defaultIncomeType } from '../data/balanceTypes'
import { DBManager } from '@ohos/common';
import { BillingDirection } from '@ohos/common/src/main/ets/DataTypes/BillingInfo';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct AddBalance {
  @State activeTab: number = 0;
  activeType: Resource = $r("app.media.salaryIcon");
  @State selectedTypeName: string = '';
  @State balanceAmount: string = "0";
  @State balanceTempAmount: string = "0";
  @State remark: string = "";
  @State calculateAction: number = 0;
  @State doneButtonText: string = "Ok";
  @State activeYear: number = router.getParams()['year'];
  @State activeMonth: number = router.getParams()['month'];
  @State activeDay: number = new Date().getDate();
  activeDate: Date = new Date();
  context = getContext(this) as common.UIAbilityContext;
  filesDir = this.context.filesDir;
  balanceInputUnits: {
    content: string | Resource,
    contentType?: string,
    callback?: () => void,
    bgColor?: ResourceColor,
    foreColor?: ResourceColor
  }[] =
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
          DBManager.getInstance().addBillingInfo({
            type: {
              icon: this.activeType,
              name: this.selectedTypeName
            },
            amount: parseFloat(this.balanceAmount),
            direction: this.activeTab == 0 ? BillingDirection.OUT : BillingDirection.IN,
            timestamp: this.activeDate.getTime(),
            remark: this.remark
          })
            .then(v => {
              promptAction.showToast({ message: '添加状态' + v });
            })
        }
      }
    ];

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        Row() {
          Column() {
            Text($r("app.string.balance"))
              .fontSize(16)
              .fontColor('white')
              .onClick(() => {
                this.activeTab = 0;
                this.selectedTypeName = '';
                this.balanceAmount = "0";
              })
              .border({
                width: {
                  bottom: this.activeTab == 0 ? 2 : 0
                },
                color: 'white'
              })
              .padding({ bottom: 16 })
              .margin({ top: 16, right: 16, left: 16 })
            Text($r("app.string.income"))
              .fontSize(16)
              .fontColor('white')
              .onClick(() => {
                this.activeTab = 1;
                this.selectedTypeName = '';
                this.balanceAmount = "0";
              })
              .border({
                width: {
                  bottom: this.activeTab == 1 ? 2 : 0
                },
                color: 'white'
              })
              .padding({ bottom: 16 })
              .margin({ top: 16, right: 16, left: 16 })
          }

          Text($r("app.string.cancel"))
            .fontSize(16)
            .fontColor('white')
            .onClick(() => {
              router.back()
            })
            .textAlign(TextAlign.End)
            .margin({ right: 24 })
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .height(48)
        .backgroundColor($r('app.color.main_theme_blue'))
        .width('100%')

        GridRow({ columns: 4, gutter: 12 }) {
          ForEach(this.activeTab == 0 ? defaultExpenseType : defaultIncomeType, item => {
            GridCol() {
              Column() {
                Image(item.img)
                  .backgroundColor(this.selectedTypeName == item.title ? "#ff5fbfff" : "white")
                  .borderRadius(16)
                  .width(56)
                  .height(56)
                  .padding(12)
                  .margin(8)
                  .shadow({ radius: 24, color: "gray" })
                  .onClick(() => {
                    this.selectedTypeName = item.title;
                    this.activeType = item.img;
                  })
                Text(item.title).fontSize(12)
              }.width(56)
            }
          })
        }.padding(12)
      }
      .width('100%')
      .height('100%')

      if (this.selectedTypeName !== '') {
        Column() {
          Row() {
            Text(`${this.balanceAmount}`).textAlign(TextAlign.End).width('100%').padding(8)
              .fontSize(24)
          }.height(36)

          Row() {
            TextInput({
              placeholder: $r("app.string.add_balance_remark_placeholder")
            }).borderRadius(8).margin(12).onChange(value => {
              this.remark = value;
            })
          }

          Row() {
            Text(`${this.activeYear} / ${(this.activeMonth + 1).toString()
              .padStart(2, '0')} / ${this.activeDay.toString().padStart(2, '0')}`).fontSize(16)
              .margin({ bottom: 12 }).onClick(() => {
              DatePickerDialog.show({
                start: new Date("2000-01-01"),
                onAccept: (v) => {
                  this.activeYear = v.year;
                  this.activeMonth = v.month;
                  this.activeDay = v.day;
                },
                selected: this.activeDate
              })
            })
          }

          GridRow({ columns: 4, gutter: 0 }) {
            ForEach(this.balanceInputUnits, unit => {
              GridCol() {
                Button({ type: ButtonType.Normal }) {
                  if (unit.contentType == "image") {
                    Image(unit.content).width(18)
                  } else {
                    Text(unit.content).fontSize(18).fontColor(unit.foreColor??"black")
                  }
                }
                .height(49)
                .backgroundColor(unit.bgColor??"white")
                .width('100%')
                .borderRadius(0)
                .onClick(unit.callback??(() => {
                  return;
                }))
              }.border({
                width: {
                  top: 0.5,
                  right: 0.5,
                  bottom: 0,
                  left: 0
                },
                color: '#ffcdcdcd'
              })
            })
          }
        }
        .width('100%')
        .shadow({
          radius: 20,
          offsetY: 16
        })
        .backgroundColor(Color.White)
      }
    }
    .width('100%')
    .height('100%')
  }
}