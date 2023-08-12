// Copyright (c) 2023 Ericple
// OpenBill is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
// http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT, MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.
@Component
export struct BalanceList {
  @Link currentBillingInfo: string;
  @Link selectedMonth: number;
  @Link selectedDay: number;
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
                  Row(){
                    Text(`${((this.selectedMonth+1).toString().padStart(2,'0'))}月${((day+1).toString().padStart(2,'0'))}日`)
                      .fontColor('black')
                      .fontSize(12).textAlign(TextAlign.Start)
                      .width('100%')
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
                                .borderRadius(24)
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
                      }.margin({top: 8})
                    })
                  }.listDirection(Axis.Vertical)
                }.width('100%').padding(16)
              }
            }
          })
        }.listDirection(Axis.Vertical)
      }
    }.padding(8).width('100%')
  }
}