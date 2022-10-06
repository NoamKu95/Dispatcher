import Foundation

class SettingsRepository {
    
    let userDefaultsManager = UserDefaultsManager()
    

    func getNotificationsSetting() -> SwitchStatus {
       return SwitchStatus(rawValue: userDefaultsManager.getFromUserDefaults(key: Constants.UserDefaults.SEND_NOTIFICATIONS) as! Int) ?? .off
    }
    

    func getSaveFiltersSetting() -> SwitchStatus {
        return SwitchStatus(rawValue: userDefaultsManager.getFromUserDefaults(key: Constants.UserDefaults.SAVE_FILTERS) as! Int) ?? .off
    }
    

    func getSaveSearchResultsSetting() -> SwitchStatus {
        return SwitchStatus(rawValue: userDefaultsManager.getFromUserDefaults(key: Constants.UserDefaults.SAVE_SEARCH_RESULTS) as! Int) ?? .off
    }
    
    
    func updateSavedSetting(settingTitle: String, newStatus: SwitchStatus, completionHandler: @escaping () -> ()) {

        switch settingTitle {
        case Constants.AppSettings.SAVE_FILTERS:
            userDefaultsManager.setItemToUserDefaults(key: Constants.UserDefaults.SAVE_FILTERS, data: newStatus.rawValue)
        case Constants.AppSettings.SEARCH_RESULTS:
            userDefaultsManager.setItemToUserDefaults(key: Constants.UserDefaults.SAVE_SEARCH_RESULTS, data: newStatus.rawValue)
            if newStatus == .off {
                userDefaultsManager.clearSingleKeyValuePairFromUserDefaults(keyToRemove: Constants.UserDefaults.RECENT_SEARCHES)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationCenter.RECENT_SEARCHES_EMPTIED), object: nil)
            }
        case Constants.AppSettings.NOTIFICATION:
            userDefaultsManager.setItemToUserDefaults(key: Constants.UserDefaults.SEND_NOTIFICATIONS, data: newStatus.rawValue)
        default:
            print("not valid option")
        }
        completionHandler()
    }
}
