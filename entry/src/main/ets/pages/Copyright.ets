// Copyright (c) 2023 Ericple
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
        // 头像
        Image($r("app.media.authorAvatar"))
          .width(120)
          .height(120)
          .border({
            width: 3,
            color: '#FF1FA1FF',
            radius: 60
          })
          .margin({ top: 40, bottom: 16 })

        // 姓名
        Text("Ericple")
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1a1a1a')
          .margin({ bottom: 8 })

        // 简介
        Text('OpenBill 开源记账应用')
          .fontSize(14)
          .fontColor($r('app.color.text_gray'))
          .margin({ bottom: 24 })

        // 联系方式卡片
        Column() {
          Row() {
            Image($r("app.media.ic_public_opensource_info"))
              .width(20)
              .height(20)
              .margin({ right: 12 })
            Text("联系方式")
              .fontSize(16)
              .fontColor('#1a1a1a')
              .fontWeight(FontWeight.Medium)
          }
          .margin({ bottom: 12 })

          Divider()
            .color($r('app.color.divider_color'))
            .margin({ bottom: 12 })

          Row() {
            Text('📧')
              .fontSize(16)
              .margin({ right: 8 })
            Text("dev@peercat.cn")
              .fontSize(15)
              .fontColor('#333333')
          }
          .margin({ bottom: 8 })

          Row() {
            Text('📱')
              .fontSize(16)
              .margin({ right: 8 })
            Text("开源项目：oh-bill")
              .fontSize(15)
              .fontColor('#333333')
          }
        }
        .padding(20)
        .width('100%')
        .backgroundColor(Color.White)
        .borderRadius(16)
        .shadow({
          radius: 8,
          color: '#1a000000',
          offsetY: 2
        })
        .margin({ top: 16 })

        // 版权信息
        Text('基于 Mulan PSL v2 开源协议')
          .fontSize(12)
          .fontColor($r('app.color.text_gray'))
          .margin({ top: 32 })

        Text('Copyright © 2023 Ericple')
          .fontSize(12)
          .fontColor($r('app.color.text_gray'))
          .margin({ top: 8 })
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