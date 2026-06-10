// Copyright (c) 2023 Ericple
// 风风记账 is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
// http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT, MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.
import { BalanceViewer } from '../components/BalanceViewer';
import { BalanceList } from '../components/BalanceList';
import { PageEntries } from '../components/pageEntries';
import { BillingDirection, BillingInfo, BillingInfoUtils, DBManager, Logger } from '@ohos/common';
import router from '@ohos.router';

let TAG = "INDEX";

@Entry
@Component
struct Index {
  @State @Watch('onDateChange') selectedDate: Date = new Date();
  @State currentBillingInfo: BillingInfo[] = [];
  @State totalIncome: number = 0.00;
  @State totalBalance: number = 0.00;

  // 搜索筛选状态
  @State searchKeyword: string = '';
  @State filterDirection: number = -1;
  @State filterCategory: string = '';
  @State showFilterPanel: boolean = false;
  @State availableTypes: string[] = [];

  // 日期变化时的回调
  private onDateChange() {
    this.reloadBillingInfo();
  }

  private reloadBillingInfo() {
    DBManager.getInstance().getAllBillingInfo()
      .then(r => {
        this.clearCache();
        this.currentBillingInfo = r;
        // 提取所有可用分类（数组去重）
        let typeList: string[] = [];
        r.forEach((info: BillingInfo) => {
          if (info.type && info.type.name) {
            let exists = false;
            for (let j = 0; j < typeList.length; j++) {
              if (typeList[j] == info.type.name) {
                exists = true;
                break;
              }
            }
            if (!exists) {
              typeList.push(info.type.name);
            }
          }
        });
        this.availableTypes = typeList;

        // 获取选中日期的年月
        const selectedYear = this.selectedDate.getFullYear();
        const selectedMonth = this.selectedDate.getMonth();

        // 只计算选中月份的收支
        this.currentBillingInfo.forEach(info => {
          const infoDate = new Date(info.timestamp);
          if (infoDate.getFullYear() === selectedYear && infoDate.getMonth() === selectedMonth) {
            info.direction == BillingDirection.IN ? this.totalIncome += info.amount : this.totalBalance += info.amount;
          }
        })
        Logger.info(TAG, "get info success ", r);
      })
  }

  clearCache() {
    this.totalIncome = 0;
    this.totalBalance = 0;
  }

  onPageShow() {
    this.reloadBillingInfo();
  }

  aboutToAppear() {
    this.reloadBillingInfo();
  }

  build() {
    Column() {
      // 顶部标题栏 - 渐变背景
      Row() {
        Text($r("app.string.app_title"))
          .fontColor(Color.White)
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .width('100%')
          .letterSpacing(2)
      }
      .padding({ top: 28, bottom: 20 })
      .width('100%')
      .linearGradient({
        angle: 180,
        colors: [
          [$r('app.color.main_theme_gradient_start'), 0],
          [$r('app.color.main_theme_gradient_end'), 1]
        ]
      })

      BalanceViewer({
        selectedDate: $selectedDate,
        currentBillingInfo: $currentBillingInfo,
        totalIncome: $totalIncome,
        totalBalance: $totalBalance
      })
        .margin({ top: 0 })

      PageEntries({
        selectedDate: $selectedDate
      })

      // 搜索栏
      Row() {
        TextInput({ placeholder: $r('app.string.search_placeholder'), text: this.searchKeyword })
          .height(36)
          .fontSize(14)
          .layoutWeight(1)
          .backgroundColor(Color.White)
          .borderRadius(18)
          .padding({ left: 12, right: 12 })
          .onChange((v: string) => {
            this.searchKeyword = v;
          })
          .placeholderColor('#999999')
          .placeholderFont({ size: 14 })

        Button({ type: ButtonType.Normal }) {
          Row() {
            Image($r("app.media.ic_public_extract_list_light"))
              .width(16)
              .height(16)
              .margin({ right: 4 })
            Text($r('app.string.search_filter'))
              .fontSize(13)
              .fontColor(this.showFilterPanel || this.filterDirection >= 0 || this.filterCategory ? '#ffffff' : '#666666')
          }
        }
        .height(36)
        .backgroundColor(this.showFilterPanel || this.filterDirection >= 0 || this.filterCategory ? '#4a7dff' : '#f0f0f0')
        .borderRadius(18)
        .padding({ left: 12, right: 12 })
        .onClick(() => {
          this.showFilterPanel = !this.showFilterPanel;
        })
        .margin({ left: 8 })
      }
      .padding({ left: 12, right: 12, top: 8, bottom: 4 })
      .width('100%')

      // 筛选面板
      if (this.showFilterPanel) {
        Column() {
          // 收支方向
          Row() {
            Text($r('app.string.filter_direction'))
              .fontSize(13)
              .fontColor('#666666')
              .margin({ right: 12 })
            Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
              Button({ type: ButtonType.Normal }) {
                Text($r('app.string.filter_all'))
                  .fontSize(12)
                  .fontColor(this.filterDirection == -1 ? '#ffffff' : '#666666')
              }
              .height(28)
              .backgroundColor(this.filterDirection == -1 ? '#4a7dff' : '#f5f5f5')
              .borderRadius(14)
              .padding({ left: 12, right: 12 })
              .margin({ right: 8 })
              .onClick(() => {
                this.filterDirection = -1;
              })

              Button({ type: ButtonType.Normal }) {
                Text($r('app.string.filter_income'))
                  .fontSize(12)
                  .fontColor(this.filterDirection == 0 ? '#ffffff' : '#4CAF50')
              }
              .height(28)
              .backgroundColor(this.filterDirection == 0 ? '#4CAF50' : '#e8f5e9')
              .borderRadius(14)
              .padding({ left: 12, right: 12 })
              .margin({ right: 8 })
              .onClick(() => {
                this.filterDirection = this.filterDirection == 0 ? -1 : 0;
              })

              Button({ type: ButtonType.Normal }) {
                Text($r('app.string.filter_expense'))
                  .fontSize(12)
                  .fontColor(this.filterDirection == 1 ? '#ffffff' : '#ff5722')
              }
              .height(28)
              .backgroundColor(this.filterDirection == 1 ? '#ff5722' : '#fbe9e7')
              .borderRadius(14)
              .padding({ left: 12, right: 12 })
              .onClick(() => {
                this.filterDirection = this.filterDirection == 1 ? -1 : 1;
              })
            }
            .layoutWeight(1)
          }
          .width('100%')
          .padding({ top: 4, bottom: 4 })

          // 分类筛选（水平滚动）
          if (this.availableTypes.length > 0) {
            Row() {
              Text($r('app.string.filter_category'))
                .fontSize(13)
                .fontColor('#666666')
                .margin({ right: 12 })
              Scroll() {
                Row() {
                  Button({ type: ButtonType.Normal }) {
                    Text($r('app.string.filter_all'))
                      .fontSize(12)
                      .fontColor(this.filterCategory == '' ? '#ffffff' : '#666666')
                  }
                  .height(28)
                  .backgroundColor(this.filterCategory == '' ? '#4a7dff' : '#f5f5f5')
                  .borderRadius(14)
                  .padding({ left: 12, right: 12 })
                  .margin({ right: 6 })
                  .onClick(() => {
                    this.filterCategory = '';
                  })

                  ForEach(this.availableTypes, (typeName: string) => {
                    Button({ type: ButtonType.Normal }) {
                      Text(typeName)
                        .fontSize(12)
                        .fontColor(this.filterCategory == typeName ? '#ffffff' : '#666666')
                    }
                    .height(28)
                    .backgroundColor(this.filterCategory == typeName ? '#4a7dff' : '#f5f5f5')
                    .borderRadius(14)
                    .padding({ left: 12, right: 12 })
                    .margin({ right: 6 })
                    .onClick(() => {
                      this.filterCategory = this.filterCategory == typeName ? '' : typeName;
                    })
                  })
                }
              }
              .layoutWeight(1)
              .scrollable(ScrollDirection.Horizontal)
            }
            .width('100%')
            .padding({ top: 4, bottom: 4 })
          }

          // 重置按钮
          Row() {
            Blank()
            Button({ type: ButtonType.Normal }) {
              Text($r('app.string.filter_reset'))
                .fontSize(12)
                .fontColor('#999999')
            }
            .height(28)
            .backgroundColor('#f5f5f5')
            .borderRadius(14)
            .padding({ left: 16, right: 16 })
            .onClick(() => {
              this.searchKeyword = '';
              this.filterDirection = -1;
              this.filterCategory = '';
            })
          }
          .width('100%')
          .padding({ top: 4 })
        }
        .width('100%')
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .backgroundColor('#fafafa')
        .borderRadius(12)
        .margin({ left: 12, right: 12 })
      }

      BalanceList({
        currentBillingInfo: $currentBillingInfo,
        selectedDate: $selectedDate,
        totalBalance: $totalBalance,
        totalIncome: $totalIncome,
        searchKeyword: this.searchKeyword,
        filterDirection: this.filterDirection,
        filterCategory: this.filterCategory
      })
        .layoutWeight(1)
    }
    .height('100%')
    .width('100%')
    .backgroundColor($r('app.color.page_background'))
  }
}