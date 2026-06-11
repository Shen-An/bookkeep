// 风风记账 is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
// http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT, MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.
import common from '@ohos.app.ability.common';
import { BillingDirection, BillingInfo, BillingInfoUtils, DBManager, StringUtils, CurrencyManager } from '@ohos/common';
import router from '@ohos.router';
import { BusinessError } from '@ohos.base';

@Component
export struct BalanceList {
  @Link currentBillingInfo: BillingInfo[];
  @Link selectedDate: Date;
  @Link totalBalance: number;
  @Link totalIncome: number;
  @Prop searchKeyword: string = '';
  @Prop filterDirection: number = -1;
  @Prop filterCategory: string = '';
  @Prop currencySymbol: string = '¥';
  context = getContext(this) as common.UIAbilityContext;
  filesDir = this.context.filesDir;

  private confirmDelete(item: BillingInfo): void {
    AlertDialog.show({
      title: '确认删除',
      message: `确定要删除「${item.remark}」这条记录吗？`,
      autoCancel: true,
      alignment: DialogAlignment.Center,
      primaryButton: {
        value: '取消',
        action: () => {}
      },
      secondaryButton: {
        value: '删除',
        fontColor: '#ff0000',
        action: () => {
          this.doDelete(item);
        }
      }
    })
  }

  private doDelete(item: BillingInfo): void {
    if (typeof item.id !== 'number') {
      return;
    }
    DBManager.getInstance().deleteBillingInfo(item.id)
      .then((affected: number) => {
        if (affected > 0) {
          const idx = this.currentBillingInfo.findIndex((info: BillingInfo) => info.id === item.id);
          if (idx >= 0) {
            this.currentBillingInfo.splice(idx, 1);
            if (item.direction == BillingDirection.IN) {
              this.totalIncome -= item.amount;
            } else {
              this.totalBalance -= item.amount;
            }
          }
        }
      })
      .catch((e: BusinessError) => {
        console.error('delete failed', JSON.stringify(e));
      })
  }

  private getFilteredData(): BillingInfo[] {
    let result = this.currentBillingInfo;
    if (this.searchKeyword) {
      const kw = this.searchKeyword.toLowerCase().trim();
      result = result.filter((i: BillingInfo) => {
        const remarkMatch = i.remark && i.remark.toLowerCase().includes(kw);
        const typeMatch = i.type && i.type.name && i.type.name.toLowerCase().includes(kw);
        return remarkMatch || typeMatch;
      });
    }
    if (this.filterDirection >= 0) {
      result = result.filter((i: BillingInfo) => i.direction === this.filterDirection);
    }
    if (this.filterCategory) {
      result = result.filter((i: BillingInfo) => i.type && i.type.name === this.filterCategory);
    }
    return result;
  }

  build() {
    Column() {
      Row() {
        Column() {
          Text('账单明细')
            .fontSize(20)
            .fontColor('#1f2a3d')
            .fontWeight(FontWeight.Bold)
          Text(`${StringUtils.formatDate(this.selectedDate, 'M月')} · 按日期分组`)
            .fontSize(12)
            .fontColor('#8b96a8')
            .margin({ top: 3 })
        }
        .alignItems(HorizontalAlign.Start)
        Blank()
        Text(`${this.getFilteredData().length} 笔`)
          .fontSize(13)
          .fontColor('#126dff')
          .fontWeight(FontWeight.Medium)
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor('#eef6ff')
          .borderRadius(16)
      }
      .width('100%')
      .padding({ left: 18, right: 18, top: 10, bottom: 8 })

      if (this.getFilteredData().length == 0) {
        Column() {
          Image($r("app.media.ic_public_budget"))
            .width(72)
            .height(72)
            .opacity(0.18)
          Text($r("app.string.no_record"))
            .fontColor('#5f6c80')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .margin({ top: 18 })
          Text('今天还没有记录，去添加第一笔吧')
            .fontColor('#a4adba')
            .fontSize(13)
            .margin({ top: 8 })
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .height(280)
        .width('100%')
        .backgroundColor('#ffffff')
        .borderRadius(28)
        .margin({ left: 16, right: 16, top: 8, bottom: 20 })
      } else {
        Column() {
          ForEach(BillingInfoUtils.explodeMonthlyArray(this.getFilteredData(), this.selectedDate), (balances: BillingInfo[], day: number) => {
            Column() {
                if (balances.length > 0) {
                  Row() {
                    Text(`${day + 1}`)
                      .fontSize(22)
                      .fontColor('#1f2a3d')
                      .fontWeight(FontWeight.Bold)
                    Text(StringUtils.formatDate(this.selectedDate, 'M月'))
                      .fontSize(12)
                      .fontColor('#8b96a8')
                      .margin({ left: 6, top: 6 })
                    Blank()
                    Text(`共 ${balances.length} 笔`)
                      .fontSize(12)
                      .fontColor('#8b96a8')
                  }
                  .width('100%')
                  .padding({ left: 4, right: 4, bottom: 10 })
                }

                Column() {
                  ForEach(balances, (balance: BillingInfo) => {
                    Row() {
                      Row() {
                        Image(balance.type.icon)
                          .width(46)
                          .height(46)
                          .borderRadius(16)
                          .padding(11)
                          .backgroundColor(balance.direction == BillingDirection.IN ? '#eafff4' : '#fff0f1')
                          .margin({ right: 12 })

                        Column() {
                          Text(balance.remark && balance.remark.length > 0 ? balance.remark : balance.type.name)
                            .fontSize(16)
                            .fontColor('#1f2a3d')
                            .fontWeight(FontWeight.Bold)
                            .maxLines(1)
                            .textOverflow({ overflow: TextOverflow.Ellipsis })
                          Row() {
                            Text(balance.type.name)
                              .fontSize(11)
                              .fontColor('#7b8798')
                            Text(' · ')
                              .fontSize(11)
                              .fontColor('#b7c0ce')
                            Text(StringUtils.formatDate(balance.timestamp, 'h:m:s'))
                              .fontSize(11)
                              .fontColor('#7b8798')
                          }
                          .margin({ top: 5 })
                        }
                        .alignItems(HorizontalAlign.Start)
                        .layoutWeight(1)
                      }
                      .layoutWeight(1)

                      Column() {
                        Text(`${balance.direction == BillingDirection.IN ? '+' : '-'}${CurrencyManager.formatWithSymbol(balance.amount, this.currencySymbol)}`)
                          .fontSize(17)
                          .fontColor(balance.direction == BillingDirection.IN ? '#21c36f' : '#ff4d5d')
                          .fontWeight(FontWeight.Bold)
                        Text(balance.direction == BillingDirection.IN ? '收入' : '支出')
                          .fontSize(11)
                          .fontColor('#a4adba')
                          .margin({ top: 4 })
                      }
                      .alignItems(HorizontalAlign.End)
                    }
                    .width('100%')
                    .padding({ left: 14, right: 14, top: 14, bottom: 14 })
                    .backgroundColor(Color.White)
                    .borderRadius(22)
                    .margin({ bottom: 10 })
                    .shadow({ radius: 14, color: '#12000000', offsetY: 6 })
                    .onClick(() => {
                      if (typeof balance.id !== 'number') {
                        return;
                      }
                      router.pushUrl({
                        url: 'pages/addBalance',
                        params: { editId: balance.id }
                      })
                    })
                    .gesture(
                      LongPressGesture({ repeat: false, duration: 500 })
                        .onAction(() => {
                          this.confirmDelete(balance);
                        })
                    )
                  })
                }
                .width('100%')
            }
            .width('100%')
            .margin({ bottom: 10 })
          })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 4, bottom: 20 })
      }
    }
    .width('100%')
  }
}
