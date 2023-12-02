// Copyright (c) 2023 Ericple
// OpenBill is licensed under Mulan PSL v2.
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
  @State selectedDate: Date = new Date();
  @State currentBillingInfo: BillingInfo[] = [];
  @State totalIncome: number = 0.00;
  @State totalBalance: number = 0.00;

  clearCache() {
    this.totalIncome = 0;
    this.totalBalance = 0;
  }

  onPageShow() {
    DBManager.getInstance().getAllBillingInfo()
      .then(r => {
        this.clearCache();
        this.currentBillingInfo = r;
        this.currentBillingInfo.forEach(info => {
          info.direction == BillingDirection.IN ? this.totalIncome += info.amount : this.totalBalance += info.amount;
        })
        Logger.info(TAG, "get info success ", r);
        Logger.info(TAG, "explode length: ", BillingInfoUtils.explodeMonthlyArray(this.currentBillingInfo, new Date())[19]
          .length)
      })
  }

  build() {
    Column() {
      Row() {
        Text($r("app.string.app_title"))
          .fontColor(Color.White)
          .fontSize(24)
          .fontWeight(FontWeight.Normal)
          .textAlign(TextAlign.Center)
          .width('100%')
      }
      .padding(24)
      .width('100%')
      .backgroundColor($r("app.color.main_theme_blue"))

      BalanceViewer({
        selectedDate: $selectedDate,
        currentBillingInfo: $currentBillingInfo,
        totalIncome: $totalIncome,
        totalBalance: $totalBalance
      })
      PageEntries()
      BalanceList({
        currentBillingInfo: $currentBillingInfo,
        selectedDate: $selectedDate,
        totalBalance: $totalBalance,
        totalIncome: $totalIncome
      })
    }
  }
}