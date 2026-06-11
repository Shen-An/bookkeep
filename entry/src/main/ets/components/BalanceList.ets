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
  @Prop filterDirection: number = -1; // -1: all, 0: IN, 1: OUT
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
        action: () => {
          // do nothing
        }
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
      if (this.getFilteredData().length == 0) {
        Row() {
          Column() {
            Image($r("app.media.ic_public_budget"))
              .width(54)
              .height(54)
              .margin({ bottom: 14 })
              .opacity(0.22)
            Text($r("app.string.no_record"))
              .fontColor('#8a94a6')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
            Text('选择其他日期或添加一笔账单')
              .fontColor('#b0b7c3')
              .fontSize(12)
              .margin({ top: 6 })
          }
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.Center)
        }
        .height('100%')
        .width('100%')
      } else {
        List() {
          ForEach(BillingInfoUtils.explodeMonthlyArray(this.getFilteredData(), this.selectedDate), (balances: BillingInfo[], day: number) => {
            ListItem() {
              Column() {
                if (balances.length > 0) {
                  // 日期头部分组
                  Row() {
                    Text(StringUtils.formatDate(this.selectedDate, 'M月') + `${day + 1}` + "日")
                      .fontColor('#6c778a')
                      .fontSize(13)
                      .fontWeight(FontWeight.Medium)
                    
                    Blank()
                    
                    Text(`共 ${balances.length} 笔`)
                      .fontSize(11)
                      .fontColor('#9aa4b2')
                      .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                      .backgroundColor('#f1f5fb')
                      .borderRadius(10)
                  }
                  .width('100%')
                  .margin({ bottom: 10, top: 14 })
                  .padding({ left: 8, right: 8 })
                }
                List() {
                  ForEach(balances, (balance: BillingInfo) => {
                    ListItem() {
                      // 每条账单卡片
                      Row() {
                        // 左侧：图标 + 详情
                        Row() {
                          // 图标圆形背景
                          Image(balance.type.icon)
                            .width(42)
                            .height(42)
                            .borderRadius(21)
                            .padding(10)
                            .backgroundColor(balance.direction == BillingDirection.IN ? '#ffe8f8e8' : '#fffce8e8')
                            .margin({ right: 12 })
                          
                          Column() {
                            Text(balance.remark)
                              .fontSize(16)
                              .fontColor('#202938')
                              .fontWeight(FontWeight.Medium)
                              .margin({ bottom: 4 })
                              .maxLines(1)
                              .textOverflow({ overflow: TextOverflow.Ellipsis })
                            Text(StringUtils.formatDate(balance.timestamp, 'h:m:s'))
                              .fontColor('#9aa4b2')
                              .fontSize(12)
                          }
                          .alignItems(HorizontalAlign.Start)
                        }

                        // 右侧：金额（按当前汇率换算）
                        Text(`${balance.direction == BillingDirection.IN ? "+" : "-"} ${CurrencyManager.formatWithSymbol(balance.amount, this.currencySymbol)}`)
                          .fontSize(17)
                          .fontColor(balance.direction == BillingDirection.IN ? $r('app.color.income_green') : $r('app.color.expense_red'))
                          .fontWeight(FontWeight.Medium)
                      }
                      .width('100%')
                      .justifyContent(FlexAlign.SpaceBetween)
                      .padding({ left: 16, right: 16, top: 14, bottom: 14 })
                      .backgroundColor('#fbfdff')
                      .borderRadius(16)
                      .shadow({
                        radius: 10,
                        color: '#10000000',
                        offsetY: 4
                      })
                    }
                    .margin({ bottom: 10 })
                    .onClick(() => {
                      if (typeof balance.id !== 'number') {
                        return;
                      }
                      router.pushUrl({
                        url: 'pages/addBalance',
                        params: {
                          editId: balance.id
                        }
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
              }
              .width('100%')
            }
          })
        }
        .listDirection(Axis.Vertical)
        .layoutWeight(1)
        .padding({ left: 14, right: 14, top: 6, bottom: 12 })
      }
    }
    .width('100%')
    .height('100%')
  }
}