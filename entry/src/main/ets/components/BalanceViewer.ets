// Copyright (c) 2023 Ericple
// OpenBill is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
// http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT, MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.
import fs from '@ohos.file.fs';
import common from '@ohos.app.ability.common';
import { advancedTemplate } from '../data/defaultBalanceTemplate';
@Component
export struct BalanceViewer {
  @Link selectedYear: number;
  @Link selectedMonth: number;
  @Link selectedDay: number;
  @Link currentBillingInfo: string;
  @State totalIncome: number = 0.00;
  @State totalBalance: number = 0.00;
  selectedDate: Date = new Date();
  calculateTotalIncomeBalance = () => {
    const billingInfo = JSON.parse(this.currentBillingInfo);
    billingInfo.forEach(dayInfo => {

    })
  }
  build(){
    Column(){
      Row(){
        Column(){
          Row(){
            Text(`${this.selectedYear.toString()}`).fontSize(12).fontColor("gray")
            Text($r("app.string.year")).fontSize(12).fontColor("gray")
          }
        }.width('20%')
        Column(){
          Text($r("app.string.income"))
            .fontColor("gray")
            .fontSize(12)
            .textAlign(TextAlign.Start)
            .width('100%')
        }.width('40%').margin({left: 10})
        Column(){
          Text($r("app.string.balance"))
            .fontColor("gray")
            .fontSize(12)
            .textAlign(TextAlign.Start)
            .width('100%')
        }.width('40%')
      }.height(12).width('100%').backgroundColor("#255BFF")
      Row(){
        Column(){
          Button({type: ButtonType.Normal}){
            Row(){
              Text(`${(this.selectedMonth+1).toString()}`)
                .fontSize(22)
                .fontColor('white')
              Text($r("app.string.month"))
                .fontColor('white')
                .fontSize(12)
                .align(Alignment.Bottom)
                .height(22)
                .margin(2)
              Image($r("app.media.extractListIcon")).width(8).height(8).margin({top:6, left:8})
            }
          }.onClick(() => {
            DatePickerDialog.show({
              start: new Date(`2000-01-01`),
              selected: this.selectedDate,
              onAccept: (v)=>{
                this.selectedDate.setFullYear(v.year,v.month,v.day);
                this.selectedYear=v.year;
                this.selectedMonth=v.month;
                this.selectedDay=v.day;
                let context = getContext(this) as common.UIAbilityContext;
                let filesDir = context.filesDir;
                const fPath = filesDir+`/bill-${v.year}-${v.month}.json`;
                fs.access(fPath).then((exist) => {
                  if(exist){
                    fs.readText(filesDir+`/bill-${v.year}-${v.month}.json`, async (err, content) => {
                      if(err)
                        this.currentBillingInfo = JSON.stringify(advancedTemplate);
                      else
                        this.currentBillingInfo = content;
                    });
                  }
                }).catch((reason) => {
                  this.currentBillingInfo = JSON.stringify(advancedTemplate);
                })
              }
            });
          }).backgroundColor("#255BFF").width('100%').borderRadius(4)
        }.width('20%').border({
          style: BorderStyle.Solid,
          color: {right: "gray"},
          width: {right: 1}
        })
        Column(){
          Text(`${this.totalIncome.toFixed(2)}`)
            .fontColor("white")
            .fontSize(20)
            .textAlign(TextAlign.Start)
            .width('100%')
        }.width('40%').margin({left: 10})
        Column(){
          Text(`${this.totalBalance.toFixed(2)}`)
            .fontColor("white")
            .fontSize(20)
            .textAlign(TextAlign.Start)
            .width('100%')
        }.width('40%')
      }.height(52).width('100%').backgroundColor("#255BFF").padding(8)
    }.width('100%')
  }
}