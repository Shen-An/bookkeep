// Copyright (c) 2023 Ericple
// 风风记账 is licensed under Mulan PSL v2.

import router from '@ohos.router';
import { DBManager, Logger, SettingManager, BillingInfo, BillingDirection } from '@ohos/common';

let TAG = "BudgetPage";

interface CategoryBudget {
  name: string;
  limit: number;
  spent: number;
}

interface BudgetData {
  monthlyTotal: number;
  categories: CategoryBudget[];
}

@Entry
@Component
struct BudgetPage {
  @State monthlyTotal: number = 0;
  @State budgetMonth: string = '';
  @State categories: CategoryBudget[] = [];
  @State currentMonthExpense: number = 0;
  @State currencySymbol: string = '¥';
  @State editCategoryName: string = '';
  @State editCategoryLimit: string = '';
  @State showAddCategory: boolean = false;

  aboutToAppear() {
    const now = new Date();
    this.budgetMonth = `${now.getFullYear()}年${now.getMonth() + 1}月`;
    this.loadBudget();
    this.calcCurrentExpense();
  }

  private loadBudget() {
    SettingManager.getInstance().get<string>('budget_data', '').then((v: string) => {
      if (v) {
        try {
          const data: BudgetData = JSON.parse(v);
          this.monthlyTotal = data.monthlyTotal || 0;
          this.categories = data.categories || [];
        } catch (e) {
          Logger.err(TAG, 'parse budget data failed', e);
        }
      }
    });
  }

  private saveBudget() {
    const data: BudgetData = {
      monthlyTotal: this.monthlyTotal,
      categories: this.categories
    };
    SettingManager.getInstance().set('budget_data', JSON.stringify(data));
  }

  private calcCurrentExpense() {
    const now = new Date();
    const start = new Date(now.getFullYear(), now.getMonth(), 1);
    const end = new Date(now.getFullYear(), now.getMonth() + 1, 1);

    DBManager.getInstance().getAllBillingInfo().then((all: BillingInfo[]) => {
      this.currentMonthExpense = 0;
      for (let i = 0; i < all.length; i++) {
        const info = all[i];
        if (info.direction === BillingDirection.OUT &&
            info.timestamp >= start.getTime() &&
            info.timestamp < end.getTime()) {
          this.currentMonthExpense += info.amount;
        }
      }

      if (this.categories.length > 0) {
        let catSpentMap = new Map<string, number>();
        for (let i = 0; i < all.length; i++) {
          const info = all[i];
          if (info.direction === BillingDirection.OUT &&
              info.timestamp >= start.getTime() &&
              info.timestamp < end.getTime()) {
            const name = info.type && info.type.name ? info.type.name : '未分类';
            const current = catSpentMap.has(name) ? catSpentMap.get(name) as number : 0;
            catSpentMap.set(name, current + info.amount);
          }
        }

        let newCats: CategoryBudget[] = [];
        for (let i = 0; i < this.categories.length; i++) {
          const c = this.categories[i];
          const spent = catSpentMap.has(c.name) ? (catSpentMap.get(c.name) as number) : 0;
          newCats.push({ name: c.name, limit: c.limit, spent: spent });
        }
        this.categories = newCats;
      }
    });
  }

  private getProgressPercent(limit: number, spent: number): number {
    if (limit <= 0) return 0;
    return Math.min(100, spent / limit * 100);
  }

  private getRemaining(limit: number, spent: number): number {
    return Math.max(0, limit - spent);
  }

  private getBudgetProgress(): number {
    if (this.monthlyTotal <= 0) return 0;
    return Math.min(100, this.currentMonthExpense / this.monthlyTotal * 100);
  }

  private addCategory() {
    const name = this.editCategoryName.trim();
    const limit = parseFloat(this.editCategoryLimit);
    if (name && limit > 0) {
      let exists = false;
      for (let i = 0; i < this.categories.length; i++) {
        if (this.categories[i].name === name) {
          exists = true;
          break;
        }
      }
      if (!exists) {
        let newCats: CategoryBudget[] = [];
        for (let i = 0; i < this.categories.length; i++) {
          newCats.push(this.categories[i]);
        }
        newCats.push({ name: name, limit: limit, spent: 0 });
        this.categories = newCats;
        this.saveBudget();
        this.calcCurrentExpense();
      }
      this.showAddCategory = false;
    }
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Button({ type: ButtonType.Normal }) {
            Text('‹')
              .fontSize(30)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
          }
          .width(44)
          .height(44)
          .backgroundColor('#24ffffff')
          .borderRadius(16)
          .onClick(() => router.back())

          Column() {
            Text('预算管理')
              .fontColor(Color.White)
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
            Text('设定月度支出限额')
              .fontSize(12)
              .fontColor('#BFDBFE')
              .margin({ top: 3 })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
          .margin({ left: 12 })
        }
        .width('100%')
        .padding({ left: 18, right: 18, top: 28, bottom: 20 })
        .linearGradient({
          angle: 145,
          colors: [
            [$r('app.color.main_theme_gradient_start'), 0],
            [$r('app.color.main_theme_gradient_end'), 1]
          ]
        })

        Scroll() {
          Column() {
            Column() {
              Row() {
                Text('月度总预算')
                  .fontSize(16)
                  .fontColor($r('app.color.text_primary'))
                  .fontWeight(FontWeight.Bold)
                Blank()
                Text(`¥${this.monthlyTotal.toFixed(0)}`)
                  .fontSize(24)
                  .fontColor('#3B82F6')
                  .fontWeight(FontWeight.Bold)
              }
              .width('100%')

              if (this.monthlyTotal > 0) {
                Row() {
                  Row() {
                    Row()
                      .width(`${this.getBudgetProgress()}%`)
                      .height(10)
                      .backgroundColor(this.currentMonthExpense > this.monthlyTotal ? '#EF4444' : '#3B82F6')
                      .borderRadius(5)
                  }
                  .width('100%')
                  .height(10)
                  .backgroundColor('#eef3f9')
                  .borderRadius(5)
                }
                .width('100%')
                .margin({ top: 12 })

                Row() {
                  Text(`已支出 ¥${this.currentMonthExpense.toFixed(2)}`)
                    .fontSize(12)
                    .fontColor($r('app.color.text_secondary'))
                  Blank()
                  if (this.currentMonthExpense > this.monthlyTotal) {
                    Text(`超支 ¥${(this.currentMonthExpense - this.monthlyTotal).toFixed(2)}`)
                      .fontSize(12)
                      .fontColor($r('app.color.expense_red'))
                      .fontWeight(FontWeight.Bold)
                  } else {
                    Text(`剩余 ¥${this.getRemaining(this.monthlyTotal, this.currentMonthExpense).toFixed(2)}`)
                      .fontSize(12)
                      .fontColor($r('app.color.income_green'))
                  }
                }
                .width('100%')
                .margin({ top: 6 })
              }

              Row() {
                Button({ type: ButtonType.Normal }) {
                  Text(this.monthlyTotal > 0 ? '修改预算' : '设置预算')
                    .fontSize(13)
                    .fontColor('#3B82F6')
                }
                .height(32)
                .backgroundColor('#EFF6FF')
                .borderRadius(16)
                .padding({ left: 16, right: 16 })
                .margin({ right: 8 })
                .onClick(() => {
                  TextPickerDialog.show({
                    range: ['1000', '2000', '3000', '5000', '8000', '10000', '15000', '20000', '30000', '50000'],
                    selected: 0,
                    onAccept: (value: TextPickerResult) => {
                      if (value) {
                        this.monthlyTotal = parseInt(value.value as string) || 0;
                        this.saveBudget();
                      }
                    }
                  });
                })

                if (this.monthlyTotal > 0) {
                  Button({ type: ButtonType.Normal }) {
                    Text('清除')
                      .fontSize(13)
                      .fontColor($r('app.color.expense_red'))
                  }
                  .height(32)
                  .backgroundColor('#FEF2F2')
                  .borderRadius(16)
                  .padding({ left: 16, right: 16 })
                  .onClick(() => {
                    this.monthlyTotal = 0;
                    this.categories = [];
                    this.saveBudget();
                  })
                }
              }
              .width('100%')
              .margin({ top: 14 })
            }
            .width('100%')
            .padding(18)
            .backgroundColor(Color.White)
            .borderRadius(24)
            .shadow({ radius: 14, color: '#10000000', offsetY: 6 })

            Column() {
              Row() {
                Text('分类预算')
                  .fontSize(16)
                  .fontColor($r('app.color.text_primary'))
                  .fontWeight(FontWeight.Bold)
                Blank()
                Button({ type: ButtonType.Normal }) {
                  Text('+ 添加')
                    .fontSize(13)
                    .fontColor('#3B82F6')
                }
                .height(32)
                .backgroundColor('#EFF6FF')
                .borderRadius(16)
                .padding({ left: 14, right: 14 })
                .onClick(() => {
                  this.showAddCategory = true;
                  this.editCategoryName = '';
                  this.editCategoryLimit = '';
                })
              }
              .width('100%')

              if (this.categories.length == 0) {
                Column() {
                  Text('暂无分类预算')
                    .fontSize(13)
                    .fontColor($r('app.color.text_tertiary'))
                    .margin({ top: 10, bottom: 10 })
                }
                .width('100%')
              }

              ForEach(this.categories, (cat: CategoryBudget, idx: number) => {
                Column() {
                  Row() {
                    Text(cat.name)
                      .fontSize(14)
                      .fontColor($r('app.color.text_primary'))
                      .fontWeight(FontWeight.Medium)
                    Blank()
                    Text(`¥${cat.limit.toFixed(0)}`)
                      .fontSize(14)
                      .fontColor('#3B82F6')
                      .fontWeight(FontWeight.Bold)
                  }
                  .width('100%')

                  Row() {
                    Row() {
                      Row()
                        .width(`${this.getProgressPercent(cat.limit, cat.spent)}%`)
                        .height(8)
                        .backgroundColor(this.getProgressPercent(cat.limit, cat.spent) >= 100 ? '#EF4444' :
                          this.getProgressPercent(cat.limit, cat.spent) >= 80 ? '#F59E0B' : '#22C55E')
                        .borderRadius(4)
                    }
                    .width('100%')
                    .height(8)
                    .backgroundColor('#eef3f9')
                    .borderRadius(4)
                  }
                  .width('100%')
                  .margin({ top: 6 })

                  Row() {
                    Text(`已支出 ¥${cat.spent.toFixed(2)}`)
                      .fontSize(11)
                      .fontColor($r('app.color.text_tertiary'))
                    Blank()
                    if (cat.spent > cat.limit) {
                      Text('超支!')
                        .fontSize(11)
                        .fontColor($r('app.color.expense_red'))
                        .fontWeight(FontWeight.Bold)
                    } else {
                      Text(`剩余 ¥${this.getRemaining(cat.limit, cat.spent).toFixed(2)}`)
                        .fontSize(11)
                        .fontColor($r('app.color.income_green'))
                    }
                  }
                  .width('100%')
                  .margin({ top: 4 })

                  Button({ type: ButtonType.Normal }) {
                    Text('删除')
                      .fontSize(11)
                      .fontColor($r('app.color.expense_red'))
                  }
                  .height(24)
                  .backgroundColor('#FEF2F2')
                  .borderRadius(12)
                  .padding({ left: 10, right: 10 })
                  .margin({ top: 6 })
                  .onClick(() => {
                    let newCats: CategoryBudget[] = [];
                    for (let i = 0; i < this.categories.length; i++) {
                      if (i !== idx) {
                        newCats.push(this.categories[i]);
                      }
                    }
                    this.categories = newCats;
                    this.saveBudget();
                  })
                }
                .width('100%')
                .padding(14)
                .backgroundColor('#FAFAFA')
                .borderRadius(18)
                .margin({ top: 10 })
              })
            }
            .width('100%')
            .padding(18)
            .backgroundColor(Color.White)
            .borderRadius(24)
            .margin({ top: 14, bottom: 28 })
            .shadow({ radius: 14, color: '#10000000', offsetY: 6 })
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 16 })
        }
        .layoutWeight(1)
        .width('100%')
      }
      .height('100%')
      .width('100%')
      .backgroundColor($r('app.color.page_background'))

      if (this.showAddCategory) {
        Column() {
          Column() {
            Text('添加分类预算')
              .fontSize(18)
              .fontColor($r('app.color.text_primary'))
              .fontWeight(FontWeight.Bold)

            TextInput({ placeholder: '分类名称 (如 餐饮)', text: this.editCategoryName })
              .height(44)
              .fontSize(14)
              .backgroundColor('#f5f7fa')
              .borderRadius(12)
              .padding({ left: 14 })
              .margin({ top: 16 })
              .onChange((v: string) => { this.editCategoryName = v })

            TextInput({ placeholder: '预算金额', text: this.editCategoryLimit })
              .height(44)
              .fontSize(14)
              .backgroundColor('#f5f7fa')
              .borderRadius(12)
              .padding({ left: 14 })
              .margin({ top: 10 })
              .onChange((v: string) => { this.editCategoryLimit = v })

            Row() {
              Button({ type: ButtonType.Normal }) {
                Text('取消')
                  .fontSize(14)
                  .fontColor($r('app.color.text_secondary'))
              }
              .height(40)
              .layoutWeight(1)
              .backgroundColor('#f0f0f0')
              .borderRadius(20)
              .margin({ right: 8 })
              .onClick(() => {
                this.showAddCategory = false;
              })

              Button({ type: ButtonType.Normal }) {
                Text('确定')
                  .fontSize(14)
                  .fontColor(Color.White)
              }
              .height(40)
              .layoutWeight(1)
              .backgroundColor('#3B82F6')
              .borderRadius(20)
              .margin({ left: 8 })
              .onClick(() => {
                this.addCategory();
              })
            }
            .width('100%')
            .margin({ top: 20 })
          }
          .width('85%')
          .padding(24)
          .backgroundColor(Color.White)
          .borderRadius(28)
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#66000000')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .onClick(() => { this.showAddCategory = false; })
      }
    }
    .height('100%')
    .width('100%')
  }
}