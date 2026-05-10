// Copyright (c) 2023 Ericple
// 风风记账 is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
// http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT, MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.
import { BillingInfo, DBManager, Logger } from '@ohos/common';
import { CSVUtils, ImportResult } from '../utils/CSVUtils';
import { fileIo } from '@kit.CoreFileKit';
import { picker } from '@kit.CoreFileKit';
import { BusinessError } from '@ohos.base';

let TAG = "DataImport";

@Entry
@Component
struct DataImport {
  @State importStatus: string = '';
  @State isImporting: boolean = false;
  @State selectedFileName: string = '';
  @State selectedFileUri: string = '';
  @State importedCount: number = 0;
  @State previewItems: BillingInfo[] = [];
  @State showPreview: boolean = false;

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text($r("app.string.data_import_title"))
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
          // 导入说明卡片
          Column() {
            Text($r("app.string.data_import_guide"))
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .width('100%')
              .textAlign(TextAlign.Start)

            Text($r("app.string.data_import_format_desc"))
              .fontSize(14)
              .fontColor('#666666')
              .width('100%')
              .margin({ top: 8 })
              .lineHeight(22)

            // 支持的格式说明
            Column() {
              Row() {
                Text("• ")
                  .fontSize(13)
                  .fontColor('#999999')
                Text($r("app.string.data_import_support_csv"))
                  .fontSize(13)
                  .fontColor('#999999')
              }
              .width('100%')
              .margin({ top: 4 })

              Row() {
                Text("• ")
                  .fontSize(13)
                  .fontColor('#999999')
                Text($r("app.string.data_import_support_xlsx"))
                  .fontSize(13)
                  .fontColor('#999999')
              }
              .width('100%')
              .margin({ top: 4 })

              Row() {
                Text("• ")
                  .fontSize(13)
                  .fontColor('#999999')
                Text($r("app.string.data_import_support_wechat"))
                  .fontSize(13)
                  .fontColor('#999999')
              }
              .width('100%')
              .margin({ top: 4 })
            }
            .width('100%')
            .margin({ top: 8 })
          }
          .padding(16)
          .width('100%')
          .backgroundColor(Color.White)
          .borderRadius(12)
          .margin({ top: 16, left: 16, right: 16 })

          // 文件选择区域
          Column() {
            Text($r("app.string.data_import_select_file"))
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .width('100%')
              .textAlign(TextAlign.Start)

            // 已选文件显示
            if (this.selectedFileName !== '') {
              Row() {
                Text(this.selectedFileName)
                  .fontSize(14)
                  .fontColor('#333333')
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .layoutWeight(1)
              }
              .width('100%')
              .padding(12)
              .backgroundColor('#f5f5f5')
              .borderRadius(8)
              .margin({ top: 8 })
            }

            // 选择文件按钮
            Button() {
              Row() {
                Image($r("app.media.ic_public_import"))
                  .width(20)
                  .height(20)
                  .margin({ right: 6 })
                Text(this.selectedFileName === '' ?
                  $r("app.string.data_import_choose_file") :
                  $r("app.string.data_import_rechoose"))
                  .fontSize(15)
                  .fontColor(Color.White)
              }
              .justifyContent(FlexAlign.Center)
            }
            .width('100%')
            .height(44)
            .backgroundColor($r('app.color.main_theme_gradient_start'))
            .borderRadius(22)
            .margin({ top: 12 })
            .enabled(!this.isImporting)
            .onClick(() => {
              this.selectFile();
            })
          }
          .padding(16)
          .width('100%')
          .backgroundColor(Color.White)
          .borderRadius(12)
          .margin({ top: 12, left: 16, right: 16 })

          // 导入按钮
          Button() {
            Row() {
              if (this.isImporting) {
                LoadingProgress()
                  .width(24)
                  .height(24)
                  .margin({ right: 8 })
              }
              Text(this.isImporting ?
                $r("app.string.data_import_importing") :
                $r("app.string.data_import_start"))
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
          .enabled(!this.isImporting && this.selectedFileName !== '')
          .onClick(() => {
            this.doImport();
          })

          // 状态提示
          if (this.importStatus !== '') {
            Text(this.importStatus)
              .fontSize(14)
              .fontColor('#666666')
              .textAlign(TextAlign.Center)
              .width('100%')
              .margin({ top: 16, left: 16, right: 16 })
          }

            // 预览区域
            if (this.showPreview && this.previewItems.length > 0) {
              Column() {
                Text($r("app.string.data_import_preview"))
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .width('100%')
                  .textAlign(TextAlign.Start)

                List() {
                  ForEach(this.previewItems.slice(0, 10), (item: BillingInfo, index: number) => {
                    ListItem() {
                      Row() {
                        Column() {
                          Text(item.type.name)
                            .fontSize(13)
                            .fontColor('#333333')
                          Text(new Date(item.timestamp).toLocaleString())
                            .fontSize(11)
                            .fontColor('#999999')
                            .margin({ top: 2 })
                        }
                        .alignItems(HorizontalAlign.Start)
                        .layoutWeight(1)

                        Column() {
                          Text((item.direction === 0 ? "+" : "-") + item.amount.toFixed(2))
                            .fontSize(15)
                            .fontColor(item.direction === 0 ? '#27ae60' : '#e74c3c')
                            .fontWeight(FontWeight.Bold)
                          Text(item.direction === 0 ? "收入" : "支出")
                            .fontSize(11)
                            .fontColor('#999999')
                            .margin({ top: 2 })
                        }
                        .alignItems(HorizontalAlign.End)
                      }
                      .width('100%')
                      .padding({ top: 8, bottom: 8 })
                    }
                    .width('100%')
                  })
                }
                .width('100%')
                .height(320)
                .divider({ strokeWidth: 1, color: '#f0f0f0' })
                .margin({ top: 8 })
                .borderRadius(8)
                .backgroundColor('#fafafa')
                .padding(8)

                // 保存到数据库按钮
                Button() {
                  Text($r("app.string.data_import_save_to_db"))
                    .fontSize(16)
                    .fontColor(Color.White)
                }
                .width('100%')
                .height(44)
                .backgroundColor('#27ae60')
                .borderRadius(22)
                .margin({ top: 16 })
                .enabled(!this.isImporting)
                .onClick(() => {
                  this.confirmImport();
                })
              }
              .padding(16)
              .width('100%')
              .backgroundColor(Color.White)
              .borderRadius(12)
              .margin({ top: 12, left: 16, right: 16 })
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

  /**
   * 选择文件
   */
  private selectFile() {
    try {
      let documentPicker = new picker.DocumentViewPicker();
      documentPicker.select({
        maxSelectNumber: 1,
        fileSuffixFilters: ['.csv', '.xlsx']
      }).then((uris: string[]) => {
        if (uris && uris.length > 0) {
          const uri = uris[0];
          // 从 URI 中提取文件名
          const fileName = uri.substring(uri.lastIndexOf('/') + 1);
          this.selectedFileName = fileName;
          this.selectedFileUri = uri;
          this.importStatus = "已选择文件: " + fileName;
          this.showPreview = false;
          this.previewItems = [];
          this.importedCount = 0;
          Logger.info(TAG, "selected file: " + uri);
        }
      }).catch((e: BusinessError) => {
        Logger.err(TAG, "select file error: " + e.message);
        if (e.code !== 0) {
          this.importStatus = "选择文件失败: " + e.message;
        }
      });
    } catch (e) {
      Logger.err(TAG, "select file error: " + (e as Error).message);
      this.importStatus = "选择文件失败: " + (e as Error).message;
    }
  }

  /**
   * 执行导入（使用已选择的文件 URI）
   */
  private async doImport() {
    if (!this.selectedFileUri) {
      this.importStatus = "请先选择文件";
      return;
    }

    this.isImporting = true;
    this.importStatus = '';
    this.showPreview = false;
    this.previewItems = [];

    try {
      let context = getContext(this);
      let result: ImportResult;

      // 判断文件类型
      const isXLSX = this.selectedFileName.toLowerCase().endsWith('.xlsx');

      if (isXLSX) {
        // XLSX 格式 - 使用已选择的文件 URI
        const fileUri = this.selectedFileUri;
        // 复制文件到应用沙箱（因为 zip.decompressFile 需要本地文件路径）
        const tempPath = context.filesDir + "/temp_import_" + new Date().getTime() + ".xlsx";
        try {
          let srcFile = fileIo.openSync(fileUri, fileIo.OpenMode.READ_ONLY);
          let dstFile = fileIo.openSync(tempPath, fileIo.OpenMode.CREATE | fileIo.OpenMode.WRITE_ONLY);
          let stat = fileIo.statSync(fileUri);
          let buf = new ArrayBuffer(stat.size);
          fileIo.readSync(srcFile.fd, buf);
          fileIo.writeSync(dstFile.fd, buf);
          fileIo.closeSync(srcFile);
          fileIo.closeSync(dstFile);
        } catch (copyErr) {
          Logger.err(TAG, "copy file error: " + (copyErr as Error).message);
          this.importStatus = "文件读取失败: " + (copyErr as Error).message;
          this.isImporting = false;
          return;
        }

        result = await CSVUtils.importWeChatXLSX(tempPath, context);

        // 清理临时文件
        try {
          fileIo.unlinkSync(tempPath);
        } catch (e) {
          Logger.err(TAG, "cleanup temp file error: " + (e as Error).message);
        }
      } else {
        // CSV 格式 - 使用已选择的文件 URI
        const fileUri = this.selectedFileUri;
        // 读取 CSV 文件内容
        let file = fileIo.openSync(fileUri, fileIo.OpenMode.READ_ONLY);
        let stat = fileIo.statSync(fileUri);
        let buf = new ArrayBuffer(stat.size);
        fileIo.readSync(file.fd, buf);
        fileIo.closeSync(file);

        // 将 ArrayBuffer 转为字符串
        let uint8Arr = new Uint8Array(buf);
        let csvText = "";
        for (let i = 0; i < uint8Arr.length; i++) {
          csvText += String.fromCharCode(uint8Arr[i]);
        }

        // 尝试先按微信格式解析，失败则按标准格式解析
        result = CSVUtils.importWeChatBill(csvText);
        if (!result.success || result.importedCount === 0) {
          result = CSVUtils.importFromCSV(csvText);
        }
      }

      // 处理导入结果
      if (result.success && result.items.length > 0) {
        this.previewItems = result.items;
        this.showPreview = true;
        this.importedCount = result.items.length;
        this.importStatus = result.message + "，请确认后点击下方按钮保存";
      } else {
        this.importStatus = result.message || "未能解析到有效数据";
      }
    } catch (e) {
      Logger.err(TAG, "import error: " + (e as Error).message);
      this.importStatus = "导入失败: " + (e as Error).message;
    } finally {
      this.isImporting = false;
    }
  }

  /**
   * 确认导入到数据库
   */
  private async confirmImport() {
    if (this.previewItems.length === 0) return;

    this.isImporting = true;
    this.importStatus = "正在保存数据...";

    try {
      let successCount = 0;
      let failCount = 0;

      for (const item of this.previewItems) {
        const result = await DBManager.getInstance().addBillingInfo(item);
        if (result > 0) {
          successCount++;
        } else {
          failCount++;
        }
      }

      this.importStatus = "导入完成！成功 " + successCount + " 条" +
        (failCount > 0 ? "，失败 " + failCount + " 条" : "");
      this.showPreview = false;
      this.previewItems = [];
      this.selectedFileName = '';
    } catch (e) {
      Logger.err(TAG, "confirm import error: " + (e as Error).message);
      this.importStatus = "保存失败: " + (e as Error).message;
    } finally {
      this.isImporting = false;
    }
  }
}