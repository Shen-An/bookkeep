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
      Row() {
        Column() {
          Text($r("app.string.data_import_title"))
            .fontColor(Color.White)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
          Text('三步完成账单迁移')
            .fontSize(12)
            .fontColor('#d8efff')
            .margin({ top: 3 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .padding({ left: 18, right: 18, top: 28, bottom: 20 })
      .width('100%')
      .linearGradient({
        angle: 145,
        colors: [
          ['#FF2CC4E1', 0],
          [$r('app.color.main_theme_gradient_start'), 0.5],
          [$r('app.color.main_theme_gradient_end'), 1]
        ]
      })

      Scroll() {
        Column() {
          Column() {
            Text('导入向导')
              .fontSize(22)
              .fontColor('#1f2a3d')
              .fontWeight(FontWeight.Bold)
              .width('100%')
            Text($r("app.string.data_import_format_desc"))
              .fontSize(13)
              .fontColor('#6a7c94')
              .lineHeight(22)
              .width('100%')
              .margin({ top: 8 })

            Row() {
              Column() {
                Text('1')
                  .fontSize(18)
                  .fontColor(Color.White)
                  .fontWeight(FontWeight.Bold)
              }
              .width(38)
              .height(38)
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
              .backgroundColor('#1FA1FF')
              .borderRadius(19)

              Column() {
                Text('选择文件')
                  .fontSize(15)
                  .fontColor('#1f2a3d')
                  .fontWeight(FontWeight.Bold)
                Text('支持 CSV / XLSX / 微信账单')
                  .fontSize(12)
                  .fontColor('#8b96a8')
                  .margin({ top: 3 })
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
              .margin({ left: 12 })
            }
            .width('100%')
            .margin({ top: 20 })

            Row() {
              Column() {
                Text('2')
                  .fontSize(18)
                  .fontColor(Color.White)
                  .fontWeight(FontWeight.Bold)
              }
              .width(38)
              .height(38)
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
              .backgroundColor(this.showPreview ? '#2ED573' : '#c7d2e1')
              .borderRadius(19)

              Column() {
                Text('解析预览')
                  .fontSize(15)
                  .fontColor('#1f2a3d')
                  .fontWeight(FontWeight.Bold)
                Text(this.showPreview ? `已解析 ${this.importedCount} 条记录` : '先选择文件后开始解析')
                  .fontSize(12)
                  .fontColor('#8b96a8')
                  .margin({ top: 3 })
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
              .margin({ left: 12 })
            }
            .width('100%')
            .margin({ top: 16 })

            Row() {
              Column() {
                Text('3')
                  .fontSize(18)
                  .fontColor(Color.White)
                  .fontWeight(FontWeight.Bold)
              }
              .width(38)
              .height(38)
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
              .backgroundColor(this.previewItems.length > 0 ? '#FFB020' : '#c7d2e1')
              .borderRadius(19)

              Column() {
                Text('确认保存')
                  .fontSize(15)
                  .fontColor('#1f2a3d')
                  .fontWeight(FontWeight.Bold)
                Text('确认无误后写入账本')
                  .fontSize(12)
                  .fontColor('#8b96a8')
                  .margin({ top: 3 })
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
              .margin({ left: 12 })
            }
            .width('100%')
            .margin({ top: 16 })
          }
          .width('100%')
          .padding(22)
          .backgroundColor(Color.White)
          .borderRadius(30)
          .shadow({ radius: 18, color: '#12000000', offsetY: 8 })

          Column() {
            Row() {
              Column() {
                Text('当前文件')
                  .fontSize(13)
                  .fontColor('#8b96a8')
                Text(this.selectedFileName === '' ? '尚未选择文件' : this.selectedFileName)
                  .fontSize(17)
                  .fontColor('#1f2a3d')
                  .fontWeight(FontWeight.Bold)
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .margin({ top: 6 })
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              Image($r("app.media.ic_public_import"))
                .width(38)
                .height(38)
            }
            .width('100%')

            Button() {
              Text(this.selectedFileName === '' ? $r("app.string.data_import_choose_file") : $r("app.string.data_import_rechoose"))
                .fontSize(16)
                .fontColor(Color.White)
                .fontWeight(FontWeight.Bold)
            }
            .width('100%')
            .height(52)
            .backgroundColor('#1FA1FF')
            .borderRadius(24)
            .margin({ top: 18 })
            .enabled(!this.isImporting)
            .onClick(() => {
              this.selectFile();
            })

            Button() {
              Row() {
                if (this.isImporting) {
                  LoadingProgress()
                    .width(22)
                    .height(22)
                    .margin({ right: 8 })
                }
                Text(this.isImporting ? $r("app.string.data_import_importing") : $r("app.string.data_import_start"))
                  .fontSize(16)
                  .fontColor(Color.White)
                  .fontWeight(FontWeight.Bold)
              }
              .justifyContent(FlexAlign.Center)
            }
            .width('100%')
            .height(52)
            .backgroundColor(this.selectedFileName === '' ? '#b7c0ce' : '#0D6EFD')
            .borderRadius(24)
            .margin({ top: 12 })
            .enabled(!this.isImporting && this.selectedFileName !== '')
            .onClick(() => {
              this.doImport();
            })
          }
          .width('100%')
          .padding(22)
          .backgroundColor(Color.White)
          .borderRadius(30)
          .margin({ top: 18 })
          .shadow({ radius: 18, color: '#12000000', offsetY: 8 })

          if (this.importStatus !== '') {
            Text(this.importStatus)
              .fontSize(14)
              .fontColor('#5f6c80')
              .lineHeight(22)
              .width('100%')
              .padding(16)
              .backgroundColor('#eef6ff')
              .borderRadius(20)
              .margin({ top: 16 })
          }

          if (this.showPreview && this.previewItems.length > 0) {
            Column() {
              Row() {
                Column() {
                  Text($r("app.string.data_import_preview"))
                    .fontSize(20)
                    .fontColor('#1f2a3d')
                    .fontWeight(FontWeight.Bold)
                  Text(`展示前 10 条，共 ${this.importedCount} 条`)
                    .fontSize(12)
                    .fontColor('#8b96a8')
                    .margin({ top: 4 })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
              }
              .width('100%')

              List() {
                ForEach(this.previewItems.slice(0, 10), (item: BillingInfo, index: number) => {
                  ListItem() {
                    Row() {
                      Column() {
                        Text(item.type.name)
                          .fontSize(15)
                          .fontColor('#1f2a3d')
                          .fontWeight(FontWeight.Bold)
                        Text(new Date(item.timestamp).toLocaleString())
                          .fontSize(11)
                          .fontColor('#8b96a8')
                          .margin({ top: 4 })
                      }
                      .alignItems(HorizontalAlign.Start)
                      .layoutWeight(1)

                      Column() {
                        Text((item.direction === 0 ? "+" : "-") + item.amount.toFixed(2))
                          .fontSize(16)
                          .fontColor(item.direction === 0 ? '#21c36f' : '#ff4d5d')
                          .fontWeight(FontWeight.Bold)
                        Text(item.direction === 0 ? "收入" : "支出")
                          .fontSize(11)
                          .fontColor('#8b96a8')
                          .margin({ top: 3 })
                      }
                      .alignItems(HorizontalAlign.End)
                    }
                    .width('100%')
                    .padding({ top: 12, bottom: 12 })
                    .border({ width: { bottom: 0.5 }, color: '#eef2f7' })
                  }
                })
              }
              .width('100%')
              .height(320)
              .margin({ top: 12 })

              Button() {
                Text($r("app.string.data_import_save_to_db"))
                  .fontSize(16)
                  .fontColor(Color.White)
                  .fontWeight(FontWeight.Bold)
              }
              .width('100%')
              .height(52)
              .backgroundColor('#2ED573')
              .borderRadius(24)
              .margin({ top: 18 })
              .enabled(!this.isImporting)
              .onClick(() => {
                this.confirmImport();
              })
            }
            .width('100%')
            .padding(22)
            .backgroundColor(Color.White)
            .borderRadius(30)
            .margin({ top: 18, bottom: 28 })
            .shadow({ radius: 18, color: '#12000000', offsetY: 8 })
          }
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 32 })
      }
      .layoutWeight(1)
      .width('100%')
    }
    .height('100%')
    .width('100%')
    .backgroundColor('#f3f7fb')
  }

  private selectFile() {
    try {
      let documentPicker = new picker.DocumentViewPicker();
      documentPicker.select({
        maxSelectNumber: 1,
        fileSuffixFilters: ['.csv', '.xlsx']
      }).then((uris: string[]) => {
        if (uris && uris.length > 0) {
          const uri = uris[0];
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
      const isXLSX = this.selectedFileName.toLowerCase().endsWith('.xlsx');

      if (isXLSX) {
        const fileUri = this.selectedFileUri;
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

        try {
          fileIo.unlinkSync(tempPath);
        } catch (e) {
          Logger.err(TAG, "cleanup temp file error: " + (e as Error).message);
        }
      } else {
        const fileUri = this.selectedFileUri;
        let file = fileIo.openSync(fileUri, fileIo.OpenMode.READ_ONLY);
        let stat = fileIo.statSync(fileUri);
        let buf = new ArrayBuffer(stat.size);
        fileIo.readSync(file.fd, buf);
        fileIo.closeSync(file);

        let uint8Arr = new Uint8Array(buf);
        let csvText = "";
        for (let i = 0; i < uint8Arr.length; i++) {
          csvText += String.fromCharCode(uint8Arr[i]);
        }

        result = CSVUtils.importWeChatBill(csvText);
        if (!result.success || result.importedCount === 0) {
          result = CSVUtils.importFromCSV(csvText);
        }
      }

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
