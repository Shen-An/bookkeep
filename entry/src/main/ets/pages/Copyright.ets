// Copyright (c) 2023 Ericple
// Copyright (c) 2025 兑泽含光 (2025124051@chd.edu.cn)
// OpenBill is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
// http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT, MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.
import router from '@ohos.router';

@Entry
@Component
struct Copyright {
  build(){
    Column() {
      // 顶部渐变栏
      Row() {
        Text('返回')
          .fontSize(15)
          .fontColor(Color.White)
          .margin({ left: 16 })
          .onClick(() => router.back());

        Blank();

        Text('开源信息')
          .fontSize(19)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
          .margin({ right: 60 })

        Blank();
      }
      .padding({ top: 20, bottom: 20 })
      .width('100%')
      .linearGradient({
        angle: 180,
        colors: [
          [$r('app.color.main_theme_gradient_start'), 0],
          [$r('app.color.main_theme_gradient_end'), 1]
        ]
      })

      // 内容区
      Column() {
        // 头像并排
        Row() {
          // Ericple
          Column() {
            Image($r("app.media.authorAvatar"))
              .width(100)
              .height(100)
              .border({
                width: 3,
                color: '#FF1FA1FF',
                radius: 50
              })
              .margin({ bottom: 8 })

            Text("Ericple")
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1a1a1a')

            Text('OpenBill(易记账)开源记账应用')
              .fontSize(12)
              .fontColor($r('app.color.text_gray'))
              .margin({ top: 4 })
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)

          // 兑泽含光
          Column() {
            Image($r("app.media.my_authorAvatar"))
              .width(100)
              .height(100)
              .border({
                width: 3,
                color: '#FF1FA1FF',
                radius: 50
              })
              .margin({ bottom: 8 })

            Text("兑泽含光")
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1a1a1a')

            Text('风风记账')
              .fontSize(12)
              .fontColor($r('app.color.text_gray'))
              .margin({ top: 4 })
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)
        }
        .width('100%')
        .margin({ top: 40, bottom: 24 })

        // 联系方式卡片（上下排布）
        // Ericple 联系方式
        Column() {
          Text("Ericple")
            .fontSize(15)
            .fontColor('#1a1a1a')
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 8 })

          Divider()
            .color($r('app.color.divider_color'))
            .margin({ bottom: 8 })

          Row() {
            Text('📧')
              .fontSize(13)
              .margin({ right: 4 })
            Text("dev@peercat.cn")
              .fontSize(12)
              .fontColor('#333333')
            Blank()
            Text('📱')
              .fontSize(13)
              .margin({ right: 4 })
            Text("易记账")
              .fontSize(12)
              .fontColor('#333333')
          }
        }
        .padding(14)
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .backgroundColor(Color.White)
        .borderRadius(12)
        .shadow({
          radius: 6,
          color: '#1a000000',
          offsetY: 2
        })
        .margin({ top: 16 })

        // 兑泽含光 联系方式
        Column() {
          Text("兑泽含光")
            .fontSize(15)
            .fontColor('#1a1a1a')
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 8 })

          Divider()
            .color($r('app.color.divider_color'))
            .margin({ bottom: 8 })

          Row() {
            Text('📧')
              .fontSize(13)
              .margin({ right: 4 })
            Text("2025124051@chd.edu.cn")
              .fontSize(12)
              .fontColor('#333333')
            Blank()
            Text('📱')
              .fontSize(13)
              .margin({ right: 4 })
            Text("风风记账")
              .fontSize(12)
              .fontColor('#333333')
          }
        }
        .padding(14)
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .backgroundColor(Color.White)
        .borderRadius(12)
        .shadow({
          radius: 6,
          color: '#1a000000',
          offsetY: 2
        })
        .margin({ top: 12 })

        // 版权信息
        Text('基于 Mulan PSL v2 开源协议')
          .fontSize(12)
          .fontColor($r('app.color.text_gray'))
          .margin({ top: 32 })

        Text('Copyright © 2023 Ericple')
          .fontSize(12)
          .fontColor($r('app.color.text_gray'))
          .margin({ top: 8 })

        Text('Copyright © 2025 兑泽含光 (2025124051@chd.edu.cn)')
          .fontSize(12)
          .fontColor($r('app.color.text_gray'))
          .margin({ top: 4 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
      .padding({ left: 24, right: 24 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }
}