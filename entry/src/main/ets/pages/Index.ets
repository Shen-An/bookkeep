// Copyright (c) 2023 Ericple
// OpenBill is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
// http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT, MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.
import { BalanceViewer } from '../components/BalanceViewer';
import fs from '@ohos.file.fs';
import common from '@ohos.app.ability.common';
import { BalanceList } from '../components/BalanceList';
import { PageEntries } from '../components/pageEntries';
import { advancedTemplate } from '../data/defaultBalanceTemplate';
import { DBManager, Logger, SettingManager } from '@ohos/common';
import promptAction from '@ohos.promptAction';

let TAG = "INDEX";

@Entry
@Component
struct Index {
  @State selectedYear: number = new Date().getFullYear();
  @State selectedMonth: number = new Date().getMonth();
  @State selectedDay: number = new Date().getDate();
  @State currentBillingInfo: string = JSON.stringify(advancedTemplate);
  @State totalIncome: number = 0.00;
  @State totalBalance: number = 0.00;
  context = getContext(this) as common.UIAbilityContext;
  filesDir = this.context.filesDir;
  calculateTotalIncomeBalance = (source: string) => {
    const billingInfo = JSON.parse(source);
    this.totalBalance = 0.00;
    this.totalIncome = 0.00;
    billingInfo.forEach(dayInfo => {
      dayInfo.forEach(info => {
        if (info.direction == "in") {
          this.totalIncome += parseFloat(info.amount);
        } else {
          this.totalBalance += parseFloat(info.amount);
        }
      })
    })
  }

  onPageShow() {
    // fs.readText(this.filesDir + `/bill-${this.selectedYear}-${this.selectedMonth}.json`, async (err, content) => {
    //   if (err) {
    //     this.currentBillingInfo = JSON.stringify(advancedTemplate);
    //     this.calculateTotalIncomeBalance(JSON.stringify(advancedTemplate));
    //   } else {
    //     this.currentBillingInfo = content;
    //     this.calculateTotalIncomeBalance(content);
    //   }
    // });
    DBManager.getInstance().getAllBillingInfo()
      .then(r => {
        Logger.info(TAG, "get info success ", r)
      })
  }

  build() {
    Flex({ direction: FlexDirection.Column }) {
      Row() {
        Text($r("app.string.app_title"))
          .fontColor(Color.White)
          .fontSize(24)
          .fontWeight(FontWeight.Normal)
          .textAlign(TextAlign.Center)
          .width('100%')
      }.height(64).width('100%').backgroundColor($r("app.color.main_theme_blue"))

      BalanceViewer({
        selectedYear: $selectedYear,
        selectedMonth: $selectedMonth,
        selectedDay: $selectedDay,
        currentBillingInfo: $currentBillingInfo,
        totalIncome: $totalIncome,
        totalBalance: $totalBalance
      })
      PageEntries({ selectedYear: $selectedYear, selectedMonth: $selectedMonth })
      BalanceList({
        currentBillingInfo: $currentBillingInfo,
        selectedMonth: $selectedMonth,
        selectedDay: $selectedDay,
        selectedYear: $selectedYear,
        totalBalance: $totalBalance,
        totalIncome: $totalIncome
      })
    }
  }
}