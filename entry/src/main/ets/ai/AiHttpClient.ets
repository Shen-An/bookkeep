import http from '@ohos.net.http';
import { BusinessError } from '@ohos.base';
import util from '@ohos.util';

export interface HttpJsonResponse {
  statusCode: number;
  headers?: Record<string, string>;
  bodyText: string;
}

function toBodyText(result: Object): string {
  if (typeof result === 'string') {
    return result;
  }
  if (result instanceof ArrayBuffer) {
    try {
      const decoder = new util.TextDecoder('utf-8');
      return decoder.decode(new Uint8Array(result));
    } catch (_e) {
      return '';
    }
  }
  try {
    return JSON.stringify(result);
  } catch (_e) {
    return '';
  }
}

export async function postJson(url: string, headers: Record<string, string>, body: object, timeoutMs: number): Promise<HttpJsonResponse> {
  const request = http.createHttp();
  try {
    return await new Promise<HttpJsonResponse>((resolve, reject) => {
      // 手动合并 headers
      const mergedHeaders: Record<string, string> = {
        'Content-Type': 'application/json'
      };
      const headerKeys = Object.keys(headers);
      for (let i = 0; i < headerKeys.length; i++) {
        const key = headerKeys[i];
        mergedHeaders[key] = headers[key];
      }

      request.request(
        url,
        {
          method: http.RequestMethod.POST,
          header: mergedHeaders,
          extraData: JSON.stringify(body),
          connectTimeout: timeoutMs,
          readTimeout: timeoutMs
        },
        (err: BusinessError, data: http.HttpResponse) => {
          if (err) {
            reject(err);
            return;
          }
          // HttpResponse 有 result 和 header 属性，直接访问
          let resultObj: Object = data.result ?? '';
          const bodyText = toBodyText(resultObj);

          let respHeaders: Record<string, string> | undefined = undefined;
          if (data.header && typeof data.header === 'object') {
            // 将 header 对象转换为 Record<string, string>
            const headerObj = data.header as Record<string, string | number | boolean>;
            const cleanHeaders: Record<string, string> = {};
            const headerKeys2 = Object.keys(headerObj);
            for (let j = 0; j < headerKeys2.length; j++) {
              const k = headerKeys2[j];
              cleanHeaders[k] = String(headerObj[k]);
            }
            respHeaders = cleanHeaders;
          }
          resolve({
            statusCode: data.responseCode,
            headers: respHeaders,
            bodyText: bodyText
          });
        }
      );
    });
  } finally {
    try {
      request.destroy();
    } catch (_e) {
      // ignore
    }
  }
}