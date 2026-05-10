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

let TAG = "INDEX";

@Entry
@Component
struct Index {
  @State @Watch('onDateChange') selectedDate: Date = new Date();
  @State currentBillingInfo: BillingInfo[] = [];
  @State totalIncome: number = 0.00;
  @State totalBalance: number = 0.00;

  // 日期变化时的回调
  private onDateChange() {
    this.reloadBillingInfo();
  }

  private reloadBillingInfo() {
    DBManager.getInstance().getAllBillingInfo()
      .then(r => {
        this.clearCache();
        this.currentBillingInfo = r;
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

      BalanceList({
        currentBillingInfo: $currentBillingInfo,
        selectedDate: $selectedDate,
        totalBalance: $totalBalance,
        totalIncome: $totalIncome
      })
        .layoutWeight(1)
    }
    .height('100%')
    .width('100%')
    .backgroundColor($r('app.color.page_background'))
  }
}