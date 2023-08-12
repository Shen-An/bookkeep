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
                    Text(`${((this.selectedMonth+1).toString().padStart(2,'0'))}/${((day+1).toString().padStart(2,'0'))}`)
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
                            Text(balance.remark)
                              .textAlign(TextAlign.Start)
                              .width('100%')
                          }.width('50%')
                          Column(){
                            Text(balance.amount)
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