// Copyright (c) 2023 Ericple
// OpenBill is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
// http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT, MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.
export interface IBillType {
  title: string; img: Resource;
}
export const defaultExpenseType: IBillType[] = [
  {title: "餐饮", img: $r("app.media.eatIcon")},
  {title: "购物", img: $r("app.media.shoppingIcon")},
  {title: "蔬菜", img: $r("app.media.vegetablesExpenseIcon")},
  {title: "日用", img: $r("app.media.dailyExpenseIcon")},
  {title: "交通", img: $r("app.media.metroExpenseIcon")},
  {title: "旅行", img: $r("app.media.travelExpenseIcon")},
  {title: "宠物", img: $r("app.media.petExpenseIcon")},
  {title: "知识", img: $r("app.media.knowledgeExpenseIcon")},
  {title: "服装", img: $r("app.media.clothExpenseIcon")},
  {title: "数码", img: $r("app.media.digitalProductExpenseIcon")},
  {title: "烟酒", img: $r("app.media.wineExpenseIcon")},
  {title: "零食", img: $r("app.media.snacksExpenseIcon")},
  {title: "医疗", img: $r("app.media.medicalExpenseIcon")},
  {title: "住房", img: $r("app.media.houseExpenseIcon")},
  {title: "儿童", img: $r("app.media.childExpenseIcon")},
  {title: "汽车", img: $r("app.media.carExpenseIcon")},
  {title: "礼物", img: $r("app.media.giftExpenseIcon")},
  {title: "捐赠", img: $r("app.media.supportExpenseIcon")}
];

export const defaultIncomeType: IBillType[] = [
  {title: "工资", img: $r("app.media.salaryIcon")},
  {title: "理财", img: $r("app.media.foundationIcon")},
  {title: "礼金", img: $r("app.media.giftMoneyIcon")},
  {title: "兼职", img: $r("app.media.partTimeIncomeIcon")},
  {title: "其它", img: $r("app.media.otherIcon")}
]