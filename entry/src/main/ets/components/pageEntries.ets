// Copyright (c) 2023 Ericple
// OpenBill is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
// http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT, MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.
import router from '@ohos.router';
import prompt from '@ohos.prompt';
@Component
export struct PageEntries {
  @Link selectedYear: number;
  @Link selectedMonth: number;
  build(){
    Row(){
      Flex({justifyContent: FlexAlign.SpaceAround}){
        Button({type: ButtonType.Normal}){
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
        }.backgroundColor('white').borderRadius(8).onClick(() => {
          router.pushUrl({
            url: "pages/BillInfoPage",
            params: {
              year: this.selectedYear
            }
          });
        })
        Button({type: ButtonType.Normal}){
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
        }.backgroundColor('white').onClick(() => {
          router.pushUrl({
            url: 'pages/Copyright'
          }, router.RouterMode.Standard, err => {
            return;
          })
        }).borderRadius(8)
        Button({type: ButtonType.Normal}){
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
        }.backgroundColor('white').borderRadius(8)
        Button({type: ButtonType.Normal}){
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
        }.stateEffect(false).backgroundColor('white').onClick(() => {
          router.pushUrl({
            url: "pages/addBalance",
            params: {
              year: this.selectedYear,
              month: this.selectedMonth
            }
          })
        }).borderRadius(8)
      }.height(64).width('100%').backgroundColor("white").borderRadius(8).padding(8).shadow({radius: 24,color: 'gray'})
    }.linearGradient({
      angle: 180,
      colors: [
        ["#255BFF", 0],
        ["#ffffff", 1]
      ],
      repeating: false
    }).padding({top: 16, left:8,right:8,bottom:8})
  }
}