// Copyright (c) 2023 Ericple
// 风风记账 is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
// http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT, MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

import { SettingManager } from '@ohos/common';

interface OnboardStep {
  icon: string;
  iconBg: string;
  title: string;
  desc: string;
  features: string[];
}

@Component
export struct OnboardingGuide {
  @Link showGuide: boolean;

  @State currentPage: number = 0;

  private pages: OnboardStep[] = [
    {
      icon: '\uD83D\uDCB3',
      iconBg: '#EEF6FF',
      title: '欢迎使用风风记账',
      desc: '简洁智能的个人账单管理工具',
      features: ['AI 智能识别', '一键快速记账', '可视化报表']
    },
    {
      icon: '\u2795',
      iconBg: '#FFF0F1',
      title: '快捷记账',
      desc: '三步完成记录，让记账不再繁琐',
      features: ['选择收支方向', '输入金额选分类', '一键保存']
    },
    {
      icon: '\uD83E\uDDE0',
      iconBg: '#F0FFF9',
      title: 'AI 智能识别',
      desc: '输入一句话或截图，自动提取账单信息',
      features: ['自然语言解析', '截图智能识别', '自动分类标签']
    },
    {
      icon: '\uD83D\uDCCA',
      iconBg: '#FFF8EE',
      title: '预算管理',
      desc: '掌握每一笔支出，消费更有计划',
      features: ['月度总额预算', '分类限额控制', '超支实时提醒']
    }
  ];

  private completeOnboarding(): void {
    SettingManager.getInstance().set('onboarding_completed', true);
    this.showGuide = false;
  }

  @Builder
  BuildIconCircle(icon: string, bg: string) {
    Column() {
      Row() {
        Text(icon)
          .fontSize(48)
      }
      .width(100)
      .height(100)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .borderRadius(50)
      .backgroundColor(bg)
      .shadow({
        radius: 20,
        color: '#1A000000',
        offsetX: 0,
        offsetY: 8
      })
    }
    .width('100%')
    .height(160)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  BuildFeatureItem(text: string) {
    Row() {
      Text('\u2713')
        .fontSize(14)
        .fontColor('#1FA1FF')
        .fontWeight(FontWeight.Bold)
        .margin({ right: 8 })
      Text(text)
        .fontSize(14)
        .fontColor('#4A4A4A')
    }
    .width('100%')
    .height(32)
  }

  build() {
    Stack() {
      // 背景
      Column() {
        Column() {
          // 图标区域
          this.BuildIconCircle(
            this.pages[this.currentPage].icon,
            this.pages[this.currentPage].iconBg
          )

          // 标题
          Text(this.pages[this.currentPage].title)
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1F2A3D')
            .margin({ top: 32, bottom: 10 })

          // 描述
          Text(this.pages[this.currentPage].desc)
            .fontSize(16)
            .fontColor('#8B96A8')
            .textAlign(TextAlign.Center)
            .margin({ bottom: 30 })

          // 特性列表
          Column() {
            ForEach(this.pages[this.currentPage].features, (feature: string) => {
              this.BuildFeatureItem(feature)
            })
          }
          .width('80%')
          .alignItems(HorizontalAlign.Start)
          .backgroundColor('#FFFFFF')
          .borderRadius(20)
          .shadow({
            radius: 12,
            color: '#0A000000',
            offsetX: 0,
            offsetY: 4
          })
          .padding({ top: 10, bottom: 10, left: 16, right: 16 })
          .margin({ bottom: 40 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        // 分页指示器
        Row() {
          ForEach([0, 1, 2, 3], (item: number) => {
            Row()
              .width(item === this.currentPage ? 28 : 8)
              .height(8)
              .borderRadius(4)
              .backgroundColor(item === this.currentPage ? '#1FA1FF' : '#E0E6ED')
              .margin({ right: 8 })
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ bottom: 20 })

        // 按钮
        if (this.currentPage < 3) {
          Row() {
            Button({ type: ButtonType.Normal }) {
              Text('跳过')
                .fontSize(15)
                .fontColor('#8B96A8')
                .fontWeight(FontWeight.Medium)
            }
            .width('40%')
            .height(50)
            .backgroundColor('#F5F7FA')
            .borderRadius(25)
            .onClick(() => {
              this.completeOnboarding();
            })

            Blank()

            Button({ type: ButtonType.Normal }) {
              Text('下一步')
                .fontSize(16)
                .fontColor(Color.White)
                .fontWeight(FontWeight.Bold)
            }
            .width('40%')
            .height(50)
            .linearGradient({
              angle: 90,
              colors: [
                ['#1FA1FF', 0],
                ['#0D6EFD', 1]
              ]
            })
            .borderRadius(25)
            .shadow({
              radius: 14,
              color: '#331FA1FF',
              offsetX: 0,
              offsetY: 6
            })
            .onClick(() => {
              this.currentPage++;
            })
          }
          .width('100%')
          .padding({ left: 30, right: 30 })
          .margin({ bottom: 50 })
        } else {
          Button({ type: ButtonType.Normal }) {
            Text('开始使用')
              .fontSize(18)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
          }
          .width('70%')
          .height(54)
          .linearGradient({
            angle: 90,
            colors: [
              ['#1FA1FF', 0],
              ['#0D6EFD', 1]
            ]
          })
          .borderRadius(27)
          .shadow({
            radius: 16,
            color: '#441FA1FF',
            offsetX: 0,
            offsetY: 8
          })
          .onClick(() => {
            this.completeOnboarding();
          })
          .margin({ bottom: 50 })
        }
      }
      .width('100%')
      .height('100%')
      .linearGradient({
        angle: 135,
        colors: [
          ['#EEF6FF', 0],
          ['#F5F7FA', 0.5],
          ['#F0FFF9', 1]
        ]
      })
    }
    .width('100%')
    .height('100%')
  }
}
