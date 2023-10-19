import relationalStore from '@ohos.data.relationalStore';

export const CommonConfiguration = {
  SETTING_PREFERENCE_STORE_KEY: "bill_setting",
  DB_MANAGER: {
    DB_FILE_NAME: 'OH_BILL.db',
    SECURITY_LEVEL: relationalStore.SecurityLevel.S1,
    SQL: {
      INITIALIZE: "CREATE TABLE IF NOT EXISTS BILLING (ID INTEGER PRIMARY KEY AUTOINCREMENT, TYPE TEXT NOT NULL, AMOUNT REAL NOT NULL, DIRECTION INTEGER NOT NULL,TIMESTAMP UNSIGNED BIG INT, REMARK TEXT, IMAGE TEXT);CREATE TABLE IF NOT EXISTS BILLING_TYPE (ID INTEGER PRIMARY KEY AUTOINCREMENT,ICON TEXT NOT NULL, NAME TEXT NOT NULL);",
      GET_ALL_BILLINGS: "SELECT * FROM BILLING;",
      SEARCH_BILLINGS: "SELECT * FROM BILLING WHERE TYPE = ? OR REMARK LIKE '%?%';",
      SEARCH_BY_DATE_RANGE: "SELECT * FROM BILLING WHERE TIMESTAMP > ? AND TIMESTAMP < ?;",
      GET_ALL_TYPES: "SELECT * FROM BILLING_TYPE;"
    },
    TABLES: {
      BILLING: {
        NAME: 'BILLING',
        COLUMNS: {
          ID: 'ID',
          TYPE: 'TYPE',
          AMOUNT: 'AMOUNT',
          DIRECTION: 'DIRECTION',
          IMAGE: 'IMAGE',
          DATE: 'DATE',
          REMARK: 'REMARK'
        }
      },
      BILLING_TYPE: {
        NAME: 'BILLING_TYPE',
        COLUMNS: {
          ID: 'ID',
          TYPE_NAME: 'NAME'
        }
      }
    }
  }
}

export type SettingType = string | boolean | number;