// Copyright (c) 2023 Ericple
// OpenBill is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
// http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT, MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.
import router from '@ohos.router'
import fs from '@ohos.file.fs';
import { advancedTemplate } from '../data/defaultBalanceTemplate';
@Entry
@Component
export struct BillInfoPage {
  @State activeYear: number = router.getParams()["year"];
  @State janBill: string = JSON.stringify(advancedTemplate);
  @State febBill: string = JSON.stringify(advancedTemplate);
  @State marBill: string = JSON.stringify(advancedTemplate);
  @State aprBill: string = JSON.stringify(advancedTemplate);
  @State mayBill: string = JSON.stringify(advancedTemplate);
  @State junBill: string = JSON.stringify(advancedTemplate);
  @State julBill: string = JSON.stringify(advancedTemplate);
  @State augBill: string = JSON.stringify(advancedTemplate);
  @State sepBill: string = JSON.stringify(advancedTemplate);
  @State octBill: string = JSON.stringify(advancedTemplate);
  @State novBill: string = JSON.stringify(advancedTemplate);
  @State decBill: string = JSON.stringify(advancedTemplate);
  onPageShow(){
    // 读取一月
  }
  build(){
    Flex({justifyContent: FlexAlign.SpaceBetween, direction: FlexDirection.Column}){
      Row(){
        Flex({direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween}){
          Column(){
            Row(){
              Text(`${this.activeYear}`)
                .fontSize(16)
              Text($r("app.string.year")).fontSize(14)
              Image($r("app.media.extractListIconDark")).width(8).height(8).margin({left: 8})
            }.onClick(() => {
              DatePickerDialog.show({
                start: new Date("2000-01-01"),
                onAccept: (v) => {
                  this.activeYear = v.year;
                }
              })
            })
          }
        }
      }.height(36).margin(16)
      Row(){
        Flex({direction: FlexDirection.Column, justifyContent: FlexAlign.SpaceAround}){
          Text("年结余").fontSize(14).fontColor('#ffffff').margin(4).height(22)
          Text("-248.81").fontSize(28).fontColor('#ffffff').margin(4).height(36)
          Row(){
            Text("年收入 0.00").textAlign(TextAlign.Start).width('50%').fontColor('#ffffff').fontSize(14).margin({top: 16}).height(30)
            Text("年支出 0.00").width('50%').fontColor('#ffffff').fontSize(14).margin({top: 16}).height(30)
          }
        }.padding({left: 24, right: 24, top: 16, bottom: 16})
      }.height(132).backgroundColor($r("app.color.main_theme_blue")).margin(16).borderRadius(12)
      Row(){
        Column(){
          Flex({direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween}){
            Text("月份").fontSize(12).fontColor($r("app.color.text_gray"))
            Text("月收入").fontSize(12).fontColor($r("app.color.text_gray"))
            Text("月支出").fontSize(12).fontColor($r("app.color.text_gray"))
            Text("月结余").fontSize(12).fontColor($r("app.color.text_gray"))
          }
          Row(){
            List(){
              ListItem(){
                Flex({direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween}){
                  Text("8月").fontSize(16)
                  Text("0.00").fontSize(16)
                  Text("248.81").fontSize(16)
                  Text("-248.81").fontSize(16)
                }.padding(12).border({
                  width:{top: 0.5},
                  color: $r("app.color.text_gray")
                })
              }
            }.listDirection(Axis.Vertical)
          }
        }
      }.margin(16).height('70%')
    }
  }
}