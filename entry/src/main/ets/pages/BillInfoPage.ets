// Copyright (c) 2023 Ericple
// OpenBill is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
// http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT, MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.
import router from '@ohos.router'
import { BillingDirection, BillingInfo, BillingInfoUtils, DBManager, Logger, StringUtils } from '@ohos/common';

let TAG = "BillInfoPage"

@Entry
@Component
struct BillInfoPage {
  @State activeDate: Date = new Date();
  @State monthlySepBillInfo: BillingInfo[][] = [];
  @State yearlyLeft: number = 0;
  @State yearlyOutBill: number = 0;
  @State yearlyIncome: number = 0;

  clearCache() {
    this.yearlyLeft = 0;
    this.yearlyOutBill = 0;
    this.yearlyIncome = 0;
  }

  onPageShow() {
    DBManager.getInstance().getAllBillingInfo()
      .then(r => {
        this.clearCache();
        Logger.info(TAG, "activeDate:", StringUtils.formatDate(this.activeDate, 'Y-M-D'))
        this.monthlySepBillInfo = BillingInfoUtils.explodeYearlyArray(r, this.activeDate);
        this.monthlySepBillInfo.forEach(monthlyInfo => {
          monthlyInfo.forEach(info => {
            if (info.direction == BillingDirection.IN) {
              this.yearlyLeft += info.amount;
              this.yearlyIncome += info.amount;
            } else {
              this.yearlyLeft -= info.amount;
              this.yearlyOutBill += info.amount;
            }
          })
        })
      })
  }

  build() {
    Column() {
      Row() {
        Text(`${this.activeDate.getFullYear()}`)
          .fontSize(16)
          .margin({ left: 16 })
        Text($r("app.string.year"))
          .fontSize(14)
        Image($r("app.media.ic_public_extract_list_dark"))
          .width(8)
          .height(8)
          .margin({ left: 8 })
      }.onClick(() => {
        DatePickerDialog.show({
          start: new Date("2000-01-01"),
          onAccept: (v) => {
            this.activeDate.setFullYear(v.year, v.month, v.day);
          }
        })
      })
      .height(36)
      .margin(16)
      .width('100%')

      Row() {
        Column() {
          Text("年结余").fontSize(14).fontColor('#ffffff').margin(4).height(22)
          Text(`${this.yearlyLeft}`).fontSize(28).fontColor('#ffffff').margin(4).height(36)
          Row() {
            Text(`年收入 ${this.yearlyIncome}`)
              .fontColor('#ffffff')
              .fontSize(14)
              .height(30)
            Text(`年支出 ${this.yearlyOutBill}`)
              .fontColor('#ffffff')
              .fontSize(14)
              .height(30)
          }
          .justifyContent(FlexAlign.SpaceAround)
          .width('100%')
        }.padding({ left: 24, right: 24, top: 16, bottom: 16 })
      }
      .height(132)
      .backgroundColor($r("app.color.main_theme_blue"))
      .margin({ left: 16, right: 16 })
      .borderRadius(12)
      .shadow({ radius: 12, color: $r('app.color.main_theme_shadow') })

      Row() {
        Column() {
          GridRow({ columns: 4 }) {
            GridCol() {
              Text("月份").fontSize(12).fontColor($r("app.color.text_gray"))
            }

            GridCol() {
              Text("月收入").fontSize(12).fontColor($r("app.color.text_gray"))
            }

            GridCol() {
              Text("月支出").fontSize(12).fontColor($r("app.color.text_gray"))
            }

            GridCol() {
              Text("月结余").fontSize(12).fontColor($r("app.color.text_gray"))
            }
          }
          .width('100%')
          .margin({ bottom: 8 })

          Row() {
            List() {
              ForEach(this.monthlySepBillInfo, (monthlyInfo: BillingInfo[], index: number) => {
                ListItem() {
                  GridRow({ columns: 4 }) {
                    GridCol() {
                      Text(`${index + 1}月`).fontSize(16)
                    }

                    GridCol() {
                      Text(`${BillingInfoUtils.calculateTotalIncome(monthlyInfo)}`).fontSize(14)
                    }

                    GridCol() {
                      Text(`${BillingInfoUtils.calculateTotalOutBill(monthlyInfo)}`).fontSize(14)
                    }

                    GridCol() {
                      Text(`${BillingInfoUtils.calculateTotalLeft(monthlyInfo)}`).fontSize(14)
                    }
                  }
                  .padding(12)
                  .border({
                    width: { top: 0.5 },
                    color: $r("app.color.text_gray")
                  })
                  .width('100%')
                }
              })
            }.listDirection(Axis.Vertical)
          }
          .width('100%')
        }
      }
      .padding(16)
      .width('100%')
    }
  }
}