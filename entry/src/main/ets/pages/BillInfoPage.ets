// Copyright (c) 2023 Ericple
// OpenBill is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
// http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT, MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.
import router from '@ohos.router'
import { advancedTemplate } from '../data/defaultBalanceTemplate';

@Entry
@Component
struct BillInfoPage {
  @State activeYear: number = router.getParams()["year"];

  onPageShow() {
    // 读取一月
  }

  build() {
    Column() {
      Row() {
        Text(`${this.activeYear}`)
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
            this.activeYear = v.year;
          }
        })
      })
      .height(36)
      .margin(16)
      .width('100%')

      Row() {
        Column() {
          Text("年结余").fontSize(14).fontColor('#ffffff').margin(4).height(22)
          Text("-248.81").fontSize(28).fontColor('#ffffff').margin(4).height(36)
          Row() {
            Text("年收入 0.00")
              .textAlign(TextAlign.Start)
              .fontColor('#ffffff')
              .fontSize(14)
              .height(30)
            Text("年支出 0.00")
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
          Row() {
            Text("月份").fontSize(12).fontColor($r("app.color.text_gray"))
            Text("月收入").fontSize(12).fontColor($r("app.color.text_gray"))
            Text("月支出").fontSize(12).fontColor($r("app.color.text_gray"))
            Text("月结余").fontSize(12).fontColor($r("app.color.text_gray"))
          }
          .justifyContent(FlexAlign.SpaceAround)
          .width('100%')
          .margin({ bottom: 8 })

          Row() {
            List() {
              ListItem() {
                Row() {
                  Text("8月").fontSize(16)
                  Text("0.00").fontSize(16)
                  Text("248.81").fontSize(16)
                  Text("-248.81").fontSize(16)
                }
                .padding(12)
                .border({
                  width: { top: 0.5 },
                  color: $r("app.color.text_gray")
                })
                .width('100%')
                .justifyContent(FlexAlign.SpaceAround)
              }
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