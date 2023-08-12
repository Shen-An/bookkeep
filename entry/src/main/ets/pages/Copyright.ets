// Copyright (c) 2023 Ericple
// OpenBill is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
// http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT, MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.
@Entry
@Component
struct Copyright {
  build(){
    Row(){
      Column(){
        Image($r("app.media.authorAvatar")).width(128).height(128).border({
          width: 2,
          color: "#255BFF",
          radius: 64
        })
        Text("Ericple")
          .fontSize(24)
          .margin(12)
          .fontWeight(FontWeight.Bold)
          .fontColor('black')
        Text("Email: dev@peercat.cn")
          .fontColor('black')
          .margin(12)
          .fontColor('black')
      }.width('100%')
    }.height('100%').backgroundColor('white')
  }
}