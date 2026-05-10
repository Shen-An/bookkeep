// Copyright (c) 2023 Ericple
// OpenBill is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
// http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT, MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.
import { BillingInfo, DBManager, Logger } from '@ohos/common';
import { CSVUtils } from '../utils/CSVUtils';
import { fileIo } from '@kit.CoreFileKit';

let TAG = "DataExport";

@Entry
@Component
struct DataExport {
  @State allBillingInfo: BillingInfo[] = [];
  @State totalCount: number = 0;
  @State exportStatus: string = '';
  @State isExporting: boolean = false;

  aboutToAppear() {
    this.loadData();
  }

  onPageShow() {
    this.loadData();
  }

  private loadData() {
    DBManager.getInstance().getAllBillingInfo()
      .then(r => {
        this.allBillingInfo = r;
        this.totalCount = r.length;
        Logger.info(TAG, "load data success, count: " + r.length);
      })
      .catch((e: Error) => {
        Logger.err(TAG, "load data error: " + e.message);
      });
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text($r("app.string.data_export_title"))
          .fontColor(Color.White)
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .width('100%')
          .letterSpacing(2)
      }
      .padding({ top: 28, bottom: 20 })
      .width('100%')
      .linearGradient({
        angle: 180,
        colors: [
          [$r('app.color.main_theme_gradient_start'), 0],
          [$r('app.color.main_theme_gradient_end'), 1]
        ]
      })

      Scroll() {
        Column() {
          // 数据概览卡片
          Column() {
            Text($r("app.string.data_export_overview"))
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .width('100%')
              .textAlign(TextAlign.Start)

            Row() {
              Text($r("app.string.data_export_total_records"))
                .fontSize(15)
                .fontColor('#666666')
              Text(this.totalCount.toString())
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.main_theme_gradient_start'))
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .margin({ top: 12 })
          }
          .padding(16)
          .width('100%')
          .backgroundColor(Color.White)
          .borderRadius(12)
          .margin({ top: 16, left: 16, right: 16 })

          // 导出格式说明
          Column() {
            Text($r("app.string.data_export_format"))
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .width('100%')
              .textAlign(TextAlign.Start)

            Row() {
              Text("CSV")
                .fontSize(14)
                .fontColor('#666666')
              Text($r("app.string.data_export_csv_desc"))
                .fontSize(13)
                .fontColor('#999999')
                .margin({ left: 8 })
            }
            .width('100%')
            .margin({ top: 8 })
          }
          .padding(16)
          .width('100%')
          .backgroundColor(Color.White)
          .borderRadius(12)
          .margin({ top: 12, left: 16, right: 16 })

          // 导出按钮
          Button() {
            Row() {
              if (this.isExporting) {
                LoadingProgress()
                  .width(24)
                  .height(24)
                  .margin({ right: 8 })
              }
              Text(this.isExporting ?
                $r("app.string.data_export_exporting") :
                $r("app.string.data_export_start"))
                .fontSize(16)
                .fontColor(Color.White)
            }
            .justifyContent(FlexAlign.Center)
          }
          .width('100%')
          .height(48)
          .backgroundColor($r('app.color.main_theme_gradient_start'))
          .borderRadius(24)
          .margin({ top: 24, left: 16, right: 16 })
          .enabled(!this.isExporting && this.totalCount > 0)
          .onClick(() => {
            this.doExport();
          })

          // 状态提示
          if (this.exportStatus !== '') {
            Text(this.exportStatus)
              .fontSize(14)
              .fontColor('#666666')
              .textAlign(TextAlign.Center)
              .width('100%')
              .margin({ top: 16, left: 16, right: 16 })
          }
        }
        .width('100%')
        .padding({ bottom: 32 })
      }
      .layoutWeight(1)
      .width('100%')
    }
    .height('100%')
    .width('100%')
    .backgroundColor($r('app.color.page_background'))
  }

  private async doExport() {
    this.isExporting = true;
    this.exportStatus = '';

    try {
      // 生成 CSV 内容
      const csvContent = CSVUtils.exportToCSV(this.allBillingInfo);

      // 生成文件名: OpenBill_账单导出_2025-01-01_12-00-00.csv
      const now = new Date();
      const dateStr = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}`;
      const timeStr = `${String(now.getHours()).padStart(2, '0')}-${String(now.getMinutes()).padStart(2, '0')}-${String(now.getSeconds()).padStart(2, '0')}`;
      const fileName = `OpenBill_${dateStr}_${timeStr}.csv`;

      // 获取应用沙箱路径
      let context = getContext(this);
      let filesDir = context.filesDir;
      let filePath = filesDir + '/' + fileName;

      // 写入文件
      let file = fileIo.openSync(filePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.WRITE_ONLY);
      fileIo.writeSync(file.fd, csvContent);
      fileIo.closeSync(file);

      this.exportStatus = "导出成功！文件保存在: " + fileName;
      Logger.info(TAG, "export success: " + filePath);
    } catch (e) {
      Logger.err(TAG, "export error: " + (e as Error).message);
      this.exportStatus = "导出失败: " + (e as Error).message;
    } finally {
      this.isExporting = false;
    }
  }
}