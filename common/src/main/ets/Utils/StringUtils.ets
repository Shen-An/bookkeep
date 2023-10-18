export class StringUtils {
  public static formatDate(d: Date | string, format: string = 'Y-M-D'): string {
    let date: Date;
    if (typeof d == 'string') {
      date = new Date(d);
    } else {
      date = d;
    }
    let formatArray = format.split('');
    let formatLength = formatArray.length;
    let result: string = ""
    for (let i = 0;i < formatLength; i++) {
      switch (formatArray[i]) {
        case 'Y':
          result += date.getFullYear();
          break;
        case 'M':
          result += date.getMonth().toString().padStart(2, '0');
          break;
        case 'D':
          result += date.getDate().toString().padStart(2, '0');
          break;
        case 'h':
          result += date.getHours().toString().padStart(2, '0');
          break;
        case 'm':
          result += date.getMinutes().toString().padStart(2, '0');
          break;
        case 's':
          result += date.getSeconds().toString().padStart(2, '0');
          break;
        default:
          result += formatArray[i];
      }
    }
    return result;
  }
}