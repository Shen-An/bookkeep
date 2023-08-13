// Copyright (c) 2023 Ericple
// OpenBill is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
// http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT, MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.
import common from '@ohos.app.ability.common';
import fs from '@ohos.file.fs';
import {advancedTemplate} from "../data/defaultBalanceTemplate"
@Component
export struct BalanceList {
  @Link currentBillingInfo: string;
  @Link selectedYear: number;
  @Link selectedMonth: number;
  @Link selectedDay: number;
  @Link totalBalance: number;
  @Link totalIncome: number;
  context = getContext(this) as common.UIAbilityContext;
  filesDir = this.context.filesDir;
  calculateTotalIncomeBalance = (source: string) => {
    const billingInfo = JSON.parse(source);
    this.totalBalance=0.00;
    this.totalIncome=0.00;
    billingInfo.forEach(dayInfo => {
      dayInfo.forEach(info => {
        if(info.direction=="in"){
          this.totalIncome+=parseFloat(info.amount);
        }else{
          this.totalBalance+=parseFloat(info.amount);
        }
      })
    })
  }
  calculateSingleDayBalance = (dayInfo: any) => {
    let sdTotalBalance = 0;
    dayInfo.forEach(info => {
      if(info.direction=="out"){
        sdTotalBalance+=parseFloat(info.amount);
      }
    })
    return sdTotalBalance;
  }
  getDayOfWeek = (day: number) => {
    switch (day){
      case 0:
        return $r("app.string.day_of_week_sunday");
      case 1:
        return $r("app.string.day_of_week_monday");
      case 2:
        return $r("app.string.day_of_week_tuesday");
      case 3:
        return $r("app.string.day_of_week_wednesday");
      case 4:
        return $r("app.string.day_of_week_wednesday");
      case 5:
        return $r("app.string.day_of_week_friday");
      case 6:
        return $r("app.string.day_of_week_saturday");
    }
  }
  refreshBillInfo = () => {
    fs.readText(this.filesDir+`/bill-${this.selectedYear}-${this.selectedMonth}.json`, async (err, content) => {
      if(err){
        this.currentBillingInfo = JSON.stringify(advancedTemplate);
        this.calculateTotalIncomeBalance(JSON.stringify(advancedTemplate));
      } else {
        this.currentBillingInfo = content;
        this.calculateTotalIncomeBalance(content);
      }
    });
  }
  build(){
    Column(){
      if(JSON.parse(this.currentBillingInfo).length == 0){
        Row(){
          Text($r("app.string.no_record"))
            .fontColor(Color.Black)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
        }.height('100%')
      }else{
        List(){
          ForEach(JSON.parse(this.currentBillingInfo), (balances, day) => {
            if(balances.length > 0){
              ListItem(){
                Column(){
                  Flex({direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween}){
                    Text(`${((this.selectedMonth+1).toString().padStart(2,'0'))}月${((day+1).toString().padStart(2,'0'))}日`)
                      .fontSize(12).textAlign(TextAlign.Start)
                      .fontColor('#ff858585')
                    Text(this.getDayOfWeek(new Date(`${this.selectedYear}-${this.selectedMonth+1}-${day+1}`).getDay()))
                      .fontSize(12)
                      .fontColor('#ff858585')
                    Text(`支出：${this.calculateSingleDayBalance(balances)}`)
                      .fontSize(12).textAlign(TextAlign.End)
                      .fontColor('#ff858585')
                  }.border({
                    width: {bottom: 0.5},
                    color: 'gray'
                  }).padding({bottom: 8})
                  List(){
                    ForEach(balances, balance => {
                      ListItem(){
                        Row(){
                          Column(){
                            Row(){
                              Image(balance.type)
                                .width(36).height(36)
                                .borderRadius(8)
                                .padding(8)
                                .backgroundColor('#ffe2effd').margin({right: 16})
                              Text(balance.remark)
                                .textAlign(TextAlign.Start)
                                .width('100%')
                            }
                          }.width('50%')
                          Column(){
                            Text(`${balance.direction=="in"?"+":"-"} ${balance.amount}`)
                              .textAlign(TextAlign.End)
                              .width('100%')
                          }.width('50%')
                        }
                      }.margin({top: 16})
                    })
                  }.listDirection(Axis.Vertical)
                }.width('100%').padding(16)
              }
            }
          })
        }.listDirection(Axis.Vertical).height('100%')
      }
    }.padding(8).width('100%')
  }
}