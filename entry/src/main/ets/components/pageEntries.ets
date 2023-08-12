import router from '@ohos.router';
import prompt from '@ohos.prompt';
@Component
export struct PageEntries {
  @Link selectedYear: number;
  @Link selectedMonth: number;
  build(){
    Row(){
      Flex({justifyContent: FlexAlign.SpaceAround}){
        Button(){
          Column(){
            Row(){
              Image($r("app.media.balancePageIcon"))
                .width(19)
                .height(30)
            }.height(34)
            Row(){
              Text("账单")
                .fontSize(10)
                .width('100%')
                .textAlign(TextAlign.Center)
            }.height(12).width(48)
          }.width(48)
        }.stateEffect(false).backgroundColor('transparent')
        Button(){
          Column(){
            Row(){
              Image($r("app.media.copyrightPageIcon"))
                .width(22)
                .height(12)
            }.height(34)
            Row(){
              Text("开源信息")
                .fontSize(10)
                .width('100%')
                .textAlign(TextAlign.Center)
            }.height(12).width(48)
          }.width(48).alignItems(HorizontalAlign.Center)
        }.stateEffect(false).backgroundColor('transparent').onClick(() => {
          router.pushUrl({
            url: 'pages/Copyright'
          }, router.RouterMode.Standard, err => {
            return;
          })
        })
        Button(){
          Column(){
            Row(){
              Image($r("app.media.graphicPageIcon"))
                .width(27)
                .height(24.5)
            }.height(34)
            Row(){
              Text("经济图表")
                .fontSize(10)
                .width('100%')
                .textAlign(TextAlign.Center)
            }.height(12).width(48)
          }.width(48).alignItems(HorizontalAlign.Center)
        }.stateEffect(false).backgroundColor('transparent')
        Button(){
          Column(){
            Row(){
              Image($r("app.media.addBalancePageIcon"))
                .width(27)
                .height(24.5)
            }.height(34)
            Row(){
              Text("记账")
                .fontSize(10)
                .width('100%')
                .textAlign(TextAlign.Center)
            }.height(12).width(48)
          }.width(48).alignItems(HorizontalAlign.Center)
        }.stateEffect(false).backgroundColor('transparent').onClick(() => {
          router.pushUrl({
            url: "pages/addBalance",
            params: {
              year: this.selectedYear,
              month: this.selectedMonth
            }
          })
        })
      }.height(64).width('100%').backgroundColor("white").borderRadius(4).padding(8)
    }.linearGradient({
      angle: 180,
      colors: [
        ["#255BFF", 0],
        ["#ffffff", 1]
      ],
      repeating: false
    }).padding(8)
  }
}