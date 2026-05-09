// Copyright (c) 2023 Ericple
// OpenBill is licensed under Mulan PSL v2.
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
          Text($r("app.string.no_record"))
            .fontColor(Color.Black)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
        }.height('100%')
      } else {
        List() {
          ForEach(BillingInfoUtils.explodeMonthlyArray(this.currentBillingInfo, this.selectedDate), (balances: BillingInfo[], day: number) => {
            ListItem() {
              Column() {
                if (balances.length > 0) {
                  Text(StringUtils.formatDate(this.selectedDate, 'M月') + `${day + 1}` + "日")
                    .fontColor($r('app.color.text_gray'))
                    .fontSize(14)
                    .width('100%')
                    .margin({ bottom: 4 })
                  Divider()
                    .margin({ bottom: 12 })
                }
                List() {
                  ForEach(balances, (balance: BillingInfo) => {
                    ListItem() {
                      Row() {
                        Row() {
                          Image(balance.type.icon)
                            .width(36)
                            .height(36)
                            .borderRadius(8)
                            .padding(8)
                            .backgroundColor('#ffe2effd')
                            .margin({ right: 16 })
                          Text(balance.remark)
                            .margin({ right: 16 })
                          Text(StringUtils.formatDate(balance.timestamp, 'h:m:s'))
                            .fontColor($r('app.color.text_gray'))
                            .fontSize(12)
                        }
                        Text(`${balance.direction == BillingDirection.IN ? "+" : "-"} ${balance.amount}`)
                      }
                      .width('100%')
                      .justifyContent(FlexAlign.SpaceBetween)
                    }
                    .margin({ bottom: 12 })
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
        .height('100%')
      }
    }.padding(8).width('100%')
  }
}