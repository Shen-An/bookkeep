// 风风记账 is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
// http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT, MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.
import common from '@ohos.app.ability.common';
import { BillingDirection, BillingInfo, BillingInfoUtils, DBManager, StringUtils } from '@ohos/common';
import router from '@ohos.router';
import { BusinessError } from '@ohos.base';

@Component
export struct BalanceList {
  @Link currentBillingInfo: BillingInfo[];
  @Link selectedDate: Date;
  @Link totalBalance: number;
  @Link totalIncome: number;
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

  build() {
    Column() {
      if (this.currentBillingInfo.length == 0) {
        Row() {
          Column() {
            Image($r("app.media.ic_public_budget"))
              .width(48)
              .height(48)
              .margin({ bottom: 16 })
              .opacity(0.3)
            Text($r("app.string.no_record"))
              .fontColor($r('app.color.text_gray'))
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
          }
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.Center)
        }
        .height('100%')
        .width('100%')
      } else {
        List() {
          ForEach(BillingInfoUtils.explodeMonthlyArray(this.currentBillingInfo, this.selectedDate), (balances: BillingInfo[], day: number) => {
            ListItem() {
              Column() {
                if (balances.length > 0) {
                  // 日期头部分组
                  Row() {
                    Text(StringUtils.formatDate(this.selectedDate, 'M月') + `${day + 1}` + "日")
                      .fontColor($r('app.color.text_gray'))
                      .fontSize(14)
                      .fontWeight(FontWeight.Medium)
                    
                    Blank()
                    
                    Text(`共 ${balances.length} 笔`)
                      .fontSize(12)
                      .fontColor($r('app.color.text_gray'))
                  }
                  .width('100%')
                  .margin({ bottom: 8, top: 8 })
                  .padding({ left: 4, right: 4 })
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
                            .width(40)
                            .height(40)
                            .borderRadius(20)
                            .padding(10)
                            .backgroundColor(balance.direction == BillingDirection.IN ? '#ffe8f8e8' : '#fffce8e8')
                            .margin({ right: 12 })
                          
                          Column() {
                            Text(balance.remark)
                              .fontSize(15)
                              .fontColor('#1a1a1a')
                              .fontWeight(FontWeight.Medium)
                              .margin({ bottom: 4 })
                              .maxLines(1)
                              .textOverflow({ overflow: TextOverflow.Ellipsis })
                            Text(StringUtils.formatDate(balance.timestamp, 'h:m:s'))
                              .fontColor($r('app.color.text_gray'))
                              .fontSize(12)
                          }
                          .alignItems(HorizontalAlign.Start)
                        }

                        // 右侧：金额
                        Text(`${balance.direction == BillingDirection.IN ? "+" : "-"} ¥${balance.amount.toFixed(2)}`)
                          .fontSize(16)
                          .fontColor(balance.direction == BillingDirection.IN ? $r('app.color.income_green') : $r('app.color.expense_red'))
                          .fontWeight(FontWeight.Medium)
                      }
                      .width('100%')
                      .justifyContent(FlexAlign.SpaceBetween)
                      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
                      .backgroundColor(Color.White)
                      .borderRadius(12)
                      .shadow({
                        radius: 4,
                        color: '#0d000000',
                        offsetY: 1
                      })
                    }
                    .margin({ bottom: 8 })
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
        .padding({ left: 12, right: 12, top: 8 })
      }
    }
    .width('100%')
    .height('100%')
  }
}