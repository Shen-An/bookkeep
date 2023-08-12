import {BalanceViewer} from '../components/BalanceViewer';
import fs from '@ohos.file.fs';
import common from '@ohos.app.ability.common';
import { BalanceList } from '../components/BalanceList';
import { PageEntries } from '../components/pageEntries';
import { advancedTemplate } from '../data/defaultBalanceTemplate';
@Entry
@Component
struct Index {
  @State selectedYear: number = new Date().getFullYear();
  @State selectedMonth: number = new Date().getMonth();
  @State selectedDay: number = new Date().getDate();
  @State currentBillingInfo: string = "[]";
  context = getContext(this) as common.UIAbilityContext;
  filesDir = this.context.filesDir;
  operation = fs.readText(this.filesDir+`/bill-${this.selectedYear}-${this.selectedMonth}.json`, async (err, content) => {
    if(err)
      this.currentBillingInfo = JSON.stringify(advancedTemplate);
    else
      this.currentBillingInfo = content;
  });
  build() {
    Column(){
      Row(){
        Text($r("app.string.app_title"))
          .fontColor("white")
          .fontSize(24)
          .fontWeight(FontWeight.Normal)
          .textAlign(TextAlign.Center)
          .width('100%')
      }.height(64).width('100%').backgroundColor("#255BFF")
      BalanceViewer({selectedYear: $selectedYear, selectedMonth: $selectedMonth, selectedDay: $selectedDay,
        currentBillingInfo: $currentBillingInfo})
      PageEntries({selectedYear: $selectedYear, selectedMonth: $selectedMonth})
      BalanceList({currentBillingInfo: $currentBillingInfo, selectedMonth: $selectedMonth, selectedDay: $selectedDay})
    }.width('100%')
  }
}