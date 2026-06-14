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
import { LockScreen } from '../components/LockScreen';
import { QuickAddFab } from '../components/QuickAddFab';
import { OnboardingGuide } from '../components/OnboardingGuide';
import { BillingDirection, BillingInfo, BillingInfoUtils, DBManager, Logger, CurrencyManager, SettingManager } from '@ohos/common';
import router from '@ohos.router';
import window from '@ohos.window';

let TAG = "INDEX";

interface CategoryBudgetItem {
  name: string;
  limit: number;
  spent: number;
}

interface BudgetData {
  monthlyTotal: number;
  categories: CategoryBudgetItem[];
}

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
  @State currencySymbol: string = '¥';
  @State currencyRate: number = 1.0;

  // 新手引导状态
  @State showOnboarding: boolean = false;

  // PIN 锁状态
  @State pinLocked: boolean = false;
  @State pinCode: string = '';
  @State pinSetupMode: boolean = false;
  sessionVerified: boolean = false;
  pinSetupConsumed: boolean = false;

  // 消费简报状态
  @State todayIncome: number = 0;
  @State todayExpense: number = 0;
  @State yesterdayExpense: number = 0;
  @State dailyAvgExpense: number = 0;
  @State todayCount: number = 0;
  @State todayNet: number = 0;
  @State diffPercent: number = 0;
  @State avgDiffPercent: number = 0;
  @State diffSign: string = '';
  @State avgDiffSign: string = '';
  @State diffColor: string = '#94A3B8';
  @State avgDiffColor: string = '#94A3B8';
  @State netColor: string = '#22C55E';

  // 预算状态
  @State budgetTotal: number = 0;
  @State budgetUsed: number = 0;
  @State budgetExceeded: boolean = false;

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

        // 加载消费简报
        this.refreshDailySummary();
        // 加载预算
        this.refreshBudget();
      })
  }

  private refreshDailySummary() {
    const now = new Date();
    const todayStart = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const todayEnd = new Date(todayStart.getTime() + 86400000);
    const yesterdayStart = new Date(todayStart.getTime() - 86400000);

    this.todayIncome = 0;
    this.todayExpense = 0;
    this.todayCount = 0;
    this.yesterdayExpense = 0;

    const currentMonthStart = new Date(now.getFullYear(), now.getMonth(), 1);

    let totalMonthExpense = 0;
    let daysInMonth = 0;

    for (let i = 0; i < this.currentBillingInfo.length; i++) {
      const info = this.currentBillingInfo[i];
      const ts = info.timestamp;
      const d = new Date(ts);

      if (ts >= todayStart.getTime() && ts < todayEnd.getTime()) {
        this.todayCount++;
        if (info.direction === BillingDirection.IN) {
          this.todayIncome += info.amount;
        } else {
          this.todayExpense += info.amount;
        }
      }

      if (ts >= yesterdayStart.getTime() && ts < todayStart.getTime()) {
        if (info.direction === BillingDirection.OUT) {
          this.yesterdayExpense += info.amount;
        }
      }

      if (ts >= currentMonthStart.getTime() && ts < todayEnd.getTime()) {
        if (info.direction === BillingDirection.OUT) {
          totalMonthExpense += info.amount;
        }
      }
    }

    // 计算本月已过天数
    const daysPassed = now.getDate();
    this.dailyAvgExpense = daysPassed > 0 ? totalMonthExpense / daysPassed : 0;

    // 预计算对比值（避免在 build() 中使用 const）
    this.todayNet = this.todayIncome - this.todayExpense;
    this.netColor = this.todayNet >= 0 ? '#22C55E' : '#EF4444';

    if (this.yesterdayExpense > 0) {
      const diff = this.todayExpense - this.yesterdayExpense;
      this.diffPercent = diff / this.yesterdayExpense * 100;
      this.diffSign = diff > 0 ? '+' : '';
      this.diffColor = diff > 0 ? '#EF4444' : '#22C55E';
    } else {
      this.diffPercent = 0;
      this.diffSign = '';
      this.diffColor = '#94A3B8';
    }

    if (this.dailyAvgExpense > 0) {
      const avgDiff = this.todayExpense - this.dailyAvgExpense;
      this.avgDiffPercent = avgDiff / this.dailyAvgExpense * 100;
      this.avgDiffSign = avgDiff > 0 ? '+' : '';
      this.avgDiffColor = avgDiff > 0 ? '#EF4444' : '#22C55E';
    } else {
      this.avgDiffPercent = 0;
      this.avgDiffSign = '';
      this.avgDiffColor = '#94A3B8';
    }
  }

  private refreshBudget() {
    SettingManager.getInstance().get<string>('budget_data', '').then((v: string) => {
      if (v) {
        try {
          const data: BudgetData = JSON.parse(v);
          this.budgetTotal = data.monthlyTotal || 0;
          if (this.budgetTotal > 0) {
            this.budgetUsed = this.getCurrentMonthExpense();
            this.budgetExceeded = this.budgetUsed > this.budgetTotal;
          }
        } catch (e) {
          // ignore
        }
      }
    });
  }

  private getCurrentMonthExpense(): number {
    const now = new Date();
    const monthStart = new Date(now.getFullYear(), now.getMonth(), 1).getTime();
    let total = 0;
    for (let i = 0; i < this.currentBillingInfo.length; i++) {
      const info = this.currentBillingInfo[i];
      if (info.direction === BillingDirection.OUT && info.timestamp >= monthStart) {
        total += info.amount;
      }
    }
    return total;
  }

  clearCache() {
    this.totalIncome = 0;
    this.totalBalance = 0;
  }

  onPageShow() {
    this.loadCurrency();
    this.reloadBillingInfo();

    // 检查是否有 params 中的 setupPin 标记
    const params = router.getParams() as Record<string, Object> | undefined;
    if (params && params['setupPin'] === true && !this.pinSetupConsumed) {
      this.pinSetupConsumed = true;
      this.pinSetupMode = true;
      this.pinLocked = true;
    }
  }

  aboutToAppear() {
    this.reloadBillingInfo();
    this.loadCurrency();
    this.loadCurrencyAndCheckOnboarding();
    this.checkPinLock();
    this.setupForegroundListener();
  }

  private loadCurrencyAndCheckOnboarding() {
    CurrencyManager.getInstance().init().then(() => {
      this.currencySymbol = CurrencyManager.getInstance().getSymbol();
      this.checkOnboarding();
    });
  }

  private checkOnboarding() {
    SettingManager.getInstance().get<boolean>('onboarding_completed', false).then((completed: boolean) => {
      if (!completed) {
        this.showOnboarding = true;
      }
    }).catch(() => {
      this.showOnboarding = true;
    });
  }

  private handleOnboardingComplete() {
    this.showOnboarding = false;
  }

  private handleQuickAddAdded() {
    this.reloadBillingInfo();
  }

  private setupForegroundListener() {
    try {
      window.getLastWindow(getContext(this)).then((win: window.Window) => {
        win.on('windowVisibilityChange', (visible: boolean) => {
          if (visible && !this.pinSetupMode && !this.pinLocked) {
            this.sessionVerified = false;
            this.checkPinLock();
          }
        });
      });
    } catch (_e) {
      Logger.info(TAG, 'window listener setup failed');
    }
  }

  private checkPinLock() {
    if (this.sessionVerified) {
      return;
    }
    SettingManager.getInstance().get<boolean>('pin_enabled', false).then((enabled: boolean) => {
      if (enabled) {
        SettingManager.getInstance().get<string>('pin_code', '').then((code: string) => {
          if (code) {
            this.pinCode = code;
            this.pinLocked = true;
            this.pinSetupMode = false;
          }
        });
      }
    });
  }

  private loadCurrency() {
    CurrencyManager.getInstance().init().then(() => {
      this.currencySymbol = CurrencyManager.getInstance().getSymbol();
    });
  }

  build() {
    Stack() {
      // 主内容
      Column() {
        Scroll() {
          Column() {
            BalanceViewer({
              selectedDate: $selectedDate,
              currentBillingInfo: $currentBillingInfo,
              totalIncome: $totalIncome,
              totalBalance: $totalBalance,
              currencySymbol: this.currencySymbol
            })
              .margin({ top: 0 })

            PageEntries({
              selectedDate: $selectedDate
            })

            // 今日消费简报
            if (this.todayCount > 0 || this.todayExpense > 0) {
              Column() {
                Row() {
                  // Left accent bar
                  Row()
                    .width(3)
                    .height(36)
                    .backgroundColor(this.todayNet >= 0 ? '#22C55E' : '#EF4444')
                    .borderRadius(2)
                    .margin({ right: 12 })

                  Column() {
                    Text('今日消费')
                      .fontSize(15)
                      .fontColor($r('app.color.text_primary'))
                      .fontWeight(FontWeight.Bold)
                    Text(`${this.todayCount} 笔记录`)
                      .fontSize(11)
                      .fontColor($r('app.color.text_tertiary'))
                      .margin({ top: 2 })
                  }
                  .alignItems(HorizontalAlign.Start)

                  Blank()

                  Column() {
                    Text(`-${CurrencyManager.formatWithSymbol(this.todayExpense, this.currencySymbol)}`)
                      .fontSize(18)
                      .fontColor($r('app.color.expense_red'))
                      .fontWeight(FontWeight.Bold)
                      .textAlign(TextAlign.End)
                    Text('支出')
                      .fontSize(10)
                      .fontColor($r('app.color.text_tertiary'))
                      .margin({ top: 1 })
                      .textAlign(TextAlign.End)
                  }
                  .alignItems(HorizontalAlign.End)
                  .margin({ right: 16 })

                  Column() {
                    Text(`+${CurrencyManager.formatWithSymbol(this.todayIncome, this.currencySymbol)}`)
                      .fontSize(18)
                      .fontColor($r('app.color.income_green'))
                      .fontWeight(FontWeight.Bold)
                      .textAlign(TextAlign.End)
                    Text('收入')
                      .fontSize(10)
                      .fontColor($r('app.color.text_tertiary'))
                      .margin({ top: 1 })
                      .textAlign(TextAlign.End)
                  }
                  .alignItems(HorizontalAlign.End)
                }
                .width('100%')

                // 分隔线
                Row()
                  .width('100%')
                  .height(1)
                  .backgroundColor($r('app.color.divider_color'))
                  .margin({ top: 12, bottom: 10 })

                // 对比行
                Row() {
                  if (this.yesterdayExpense > 0) {
                    Row() {
                      Text('较昨日')
                        .fontSize(11)
                        .fontColor($r('app.color.text_tertiary'))
                      Text(`${this.diffSign}${this.diffPercent.toFixed(1)}%`)
                        .fontSize(12)
                        .fontColor(this.diffColor)
                        .fontWeight(FontWeight.Bold)
                        .margin({ left: 4 })
                    }
                    .padding({ right: 12 })
                  }

                  if (this.dailyAvgExpense > 0) {
                    Row() {
                      Text('较日均')
                        .fontSize(11)
                        .fontColor($r('app.color.text_tertiary'))
                      Text(`${this.avgDiffSign}${this.avgDiffPercent.toFixed(1)}%`)
                        .fontSize(12)
                        .fontColor(this.avgDiffColor)
                        .fontWeight(FontWeight.Bold)
                        .margin({ left: 4 })
                    }
                    .padding({ right: 12 })
                  }

                  Blank()

                  if (this.todayExpense > 0) {
                    Row() {
                      Circle()
                        .width(6)
                        .height(6)
                        .fill(this.netColor)
                        .margin({ right: 6 })
                      Text(`结余 ${CurrencyManager.formatWithSymbol(this.todayNet, this.currencySymbol)}`)
                        .fontSize(12)
                        .fontColor(this.netColor)
                        .fontWeight(FontWeight.Medium)
                    }
                  }
                }
                .width('100%')

                // 预算进度
                if (this.budgetTotal > 0) {
                  Row()
                    .width('100%')
                    .height(1)
                    .backgroundColor($r('app.color.divider_color'))
                    .margin({ top: 10, bottom: 10 })

                  Row() {
                    Row() {
                      Row()
                        .width(`${Math.min(100, this.budgetUsed / this.budgetTotal * 100)}%`)
                        .height(6)
                        .backgroundColor(this.budgetExceeded ? '#EF4444' :
                          this.budgetUsed / this.budgetTotal >= 0.8 ? '#F59E0B' : '#3B82F6')
                        .borderRadius(3)
                    }
                    .width('100%')
                    .height(6)
                    .backgroundColor('#eef3f9')
                    .borderRadius(3)
                    .layoutWeight(1)
                    .margin({ right: 10 })

                    Text(this.budgetExceeded ? '预算超支！' :
                      `预算 ${(this.budgetUsed / this.budgetTotal * 100).toFixed(0)}%`)
                      .fontSize(11)
                      .fontColor(this.budgetExceeded ? '#EF4444' : '#94A3B8')
                      .fontWeight(this.budgetExceeded ? FontWeight.Bold : FontWeight.Normal)
                  }
                  .width('100%')
                }
              }
              .width('100%')
              .padding(16)
              .backgroundColor(Color.White)
              .borderRadius(20)
              .margin({ left: 14, right: 14, top: 6, bottom: 4 })
              .shadow({ radius: 12, color: '#12000000', offsetY: 4 })
            }

            // 搜索栏
            Row() {
              TextInput({ placeholder: $r('app.string.search_placeholder'), text: this.searchKeyword })
                .height(40)
                .fontSize(14)
                .layoutWeight(1)
                .backgroundColor('#f6f9fd')
                .borderRadius(20)
                .padding({ left: 14, right: 14 })
                .onChange((v: string) => {
                  this.searchKeyword = v;
                })
                .placeholderColor('#94A3B8')
                .placeholderFont({ size: 14 })

              Button({ type: ButtonType.Normal }) {
                Row() {
                  Image($r("app.media.ic_public_extract_list_light"))
                    .width(16)
                    .height(18)
                    .margin({ right: 6 })
                  Text($r('app.string.search_filter'))
                    .fontSize(13)
                    .fontColor(this.showFilterPanel || this.filterDirection >= 0 || this.filterCategory ? '#ffffff' : '#475569')
                }
              }
              .height(40)
              .backgroundColor(this.showFilterPanel || this.filterDirection >= 0 || this.filterCategory ? '#3B82F6' : '#f2f6fb')
              .borderRadius(20)
              .padding({ left: 14, right: 14 })
              .onClick(() => {
                this.showFilterPanel = !this.showFilterPanel;
              })
              .margin({ left: 8 })
            }
            .padding({ left: 14, right: 14, top: 8, bottom: 6 })
            .width('100%')
            .backgroundColor('#00ffffff')

            // 筛选面板
            if (this.showFilterPanel) {
              Column() {
                // 收支方向
                Row() {
                  Text($r('app.string.filter_direction'))
                    .fontSize(13)
                    .fontColor($r('app.color.text_secondary'))
                    .margin({ right: 12 })
                  Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
                    Button({ type: ButtonType.Normal }) {
                      Text($r('app.string.filter_all'))
                        .fontSize(12)
                        .fontColor(this.filterDirection == -1 ? '#ffffff' : '#475569')
                    }
                    .height(28)
                    .backgroundColor(this.filterDirection == -1 ? '#3B82F6' : '#f5f5f5')
                    .borderRadius(14)
                    .padding({ left: 12, right: 12 })
                    .margin({ right: 8 })
                    .onClick(() => {
                      this.filterDirection = -1;
                    })

                    Button({ type: ButtonType.Normal }) {
                      Text($r('app.string.filter_income'))
                        .fontSize(12)
                        .fontColor(this.filterDirection == 0 ? '#ffffff' : '#22C55E')
                    }
                    .height(28)
                    .backgroundColor(this.filterDirection == 0 ? '#22C55E' : '#e8f5e9')
                    .borderRadius(14)
                    .padding({ left: 12, right: 12 })
                    .margin({ right: 8 })
                    .onClick(() => {
                      this.filterDirection = this.filterDirection == 0 ? -1 : 0;
                    })

                    Button({ type: ButtonType.Normal }) {
                      Text($r('app.string.filter_expense'))
                        .fontSize(12)
                        .fontColor(this.filterDirection == 1 ? '#ffffff' : '#EF4444')
                    }
                    .height(28)
                    .backgroundColor(this.filterDirection == 1 ? '#EF4444' : '#fbe9e7')
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
                      .fontColor($r('app.color.text_secondary'))
                      .margin({ right: 12 })
                    Scroll() {
                      Row() {
                        Button({ type: ButtonType.Normal }) {
                          Text($r('app.string.filter_all'))
                            .fontSize(12)
                            .fontColor(this.filterCategory == '' ? '#ffffff' : '#475569')
                        }
                        .height(28)
                        .backgroundColor(this.filterCategory == '' ? '#3B82F6' : '#f5f5f5')
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
                              .fontColor(this.filterCategory == typeName ? '#ffffff' : '#475569')
                          }
                          .height(28)
                          .backgroundColor(this.filterCategory == typeName ? '#3B82F6' : '#f5f5f5')
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
                      .fontColor('#94A3B8')
                  }
                  .height(28)
                  .backgroundColor('#eef3f9')
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
              .padding({ left: 14, right: 14, top: 10, bottom: 10 })
              .backgroundColor('#fbfdff')
              .borderRadius(18)
              .margin({ left: 14, right: 14, top: 2, bottom: 4 })
              .shadow({ radius: 10, color: '#0f000000', offsetY: 3 })
            }

            BalanceList({
              currentBillingInfo: $currentBillingInfo,
              selectedDate: $selectedDate,
              totalBalance: $totalBalance,
              totalIncome: $totalIncome,
              searchKeyword: this.searchKeyword,
              filterDirection: this.filterDirection,
              filterCategory: this.filterCategory,
              currencySymbol: this.currencySymbol
            })
          }
          .width('100%')
        }
        .height('100%')
        .width('100%')
        .scrollable(ScrollDirection.Vertical)
        .backgroundColor($r('app.color.page_background'))
      }
      .height('100%')
      .width('100%')
      .backgroundColor($r('app.color.page_background'))

      // 快捷记账浮动按钮
      QuickAddFab({
        onSaved: () => { this.reloadBillingInfo(); }
      })

      // PIN 锁覆盖层
      if (this.pinLocked) {
        LockScreen({
          title: this.pinSetupMode ? '设置 PIN 码' : '输入 PIN 码解锁',
          correctPin: this.pinCode,
          isSetupMode: this.pinSetupMode,
          onUnlock: () => {
            this.pinLocked = false;
            this.pinSetupMode = false;
            this.sessionVerified = true;
          }
        })
      }

      // 新手引导覆盖层
      if (this.showOnboarding) {
        OnboardingGuide({
          showGuide: $showOnboarding
        })
      }
    }
    .height('100%')
    .width('100%')
  }
}
