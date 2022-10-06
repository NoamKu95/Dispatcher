import Foundation

class ProfileRepository: AuthRepository {
    
    let coreDataManager = FavoriteArticleCoreDataManager()
    
    
    func getUserData(completionHandler: @escaping (String?, Any?) -> ()) {
        let userName = userDefaultsManager.getFromUserDefaults(key: Constants.UserDefaults.CURRENT_USER_NAME) as? String
        var userImage: Any? = nil
        if userDefaultsManager.checkIfKeyExists(key: Constants.UserDefaults.CURRENT_USER_IMAGE) {
            userImage = userDefaultsManager.getFromUserDefaults(key: Constants.UserDefaults.CURRENT_USER_IMAGE)
        }
        completionHandler(userName, userImage)
    }
    
    
    func logoutUserFromApp(completionHandler: @escaping (String?) -> ()) {
        do {
            try keychainManager.removeFromKeychain(
                service: Constants.Keychain.SERVICE,
                account: Constants.Keychain.ACCOUNT_USER_EMAIL,
                secClass: kSecClassGenericPassword as String
            ) {
                self.firebaseAuthManager.logoutUser() { error in
                    if let error = error {
                        completionHandler("Error logging out from firebase: \(error)")
                    } else {
                        self.coreDataManager.clearCoreDataMemory()
                        self.userDefaultsManager.clearUserDefaultsMemory()
                        completionHandler(nil)
                    }
                }
            }
        } catch {
            completionHandler("Error in deleting from keychain: \(error.localizedDescription)")
        }
    }
}
