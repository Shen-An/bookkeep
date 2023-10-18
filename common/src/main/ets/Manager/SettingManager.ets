import preferences from '@ohos.data.preferences';
import { CommonConfiguration, SettingType } from './CommonConfiguration';
import { Logger } from '../Utils/Logger';

let TAG = "SettingManager";

export class SettingManager {
  private settingStore: preferences.Preferences;

  public constructor(context: Context) {
    preferences.getPreferences(context, CommonConfiguration.SETTING_PREFERENCE_STORE_KEY)
      .then(preference => {
        this.settingStore = preference;
      })
  }

  public static getInstance(context?: Context): SettingManager {
    if (globalThis.__settingManager__ == undefined)
      globalThis.__settingManager__ = new SettingManager(context??globalThis.context)
    return globalThis.__settingManager__;
  }

  public set(k: string, v: SettingType) {
    this.settingStore.put(k, v, () => {
      this.settingStore.flush()
    })
  }

  public async get<T extends SettingType>(k: string, def: T) {
    return await new Promise((ret) => {
      this.settingStore.has(k, (e, r) => {
          !e && r ?
        this.settingStore.get(k, def, (e, v) => {
            !e ? ret(v) : Logger.err(TAG, "error while getting value of", k, e)
        }) : ret(def);
      })
    })
  }
}