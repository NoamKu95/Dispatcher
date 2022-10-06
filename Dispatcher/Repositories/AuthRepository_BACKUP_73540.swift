import Foundation

enum userType {
    case loggedOut
    case loggedIn
}

class AuthRepository {
    
<<<<<<< HEAD
    let firebaseManager = FirebaseAuthManager()
    let userDefaults = UserDefaultsManager()
    
    func isValidEmailAddress(email: String) -> Bool {
        var isValidEmail = true
        let emailRegex = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        do {
            let regex = try NSRegularExpression(pattern: emailRegex)
            let nsString = email as NSString
            let results = regex.matches(in: email, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0
            {
                isValidEmail = false
            }
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            isValidEmail = false
        }
        
        return  isValidEmail
    }
=======
    let keychainManager = KeychainManager()
    let userDefaultsManager = UserDefaultsManager()
    let firebaseAuthManager = FirebaseAuthManager()
    let firestoreManager = FirestoreManager()
    
>>>>>>> 8df7f0343a278ba6946beb2eeb3c66be3ff4862f
    
    func checkIfLoggedIn() -> userType {
        do {
            _ = try keychainManager.fetchFromKeychain(
                service: Constants.Keychain.SERVICE,
                account: Constants.Keychain.ACCOUNT_USER_EMAIL,
                secClass: kSecClassGenericPassword as String
            )
            if firebaseAuthManager.isUserLoggedIn() {
                return .loggedIn
            }
        } catch (let error) {
            print("couldn't find email in keychain: \(error)")
        }
        return .loggedOut
    }
    
    
    func fetchCurrentUserDetails(completionHandler: @escaping (String?) -> ()) {
        let uid = firebaseAuthManager.getCurrentUserUID()
        if uid != nil {
            let docPath = "\(Constants.Firestore.USERS_COLLECTION)/\(uid!)"
            firestoreManager.fetchDocumentFromFirestore(documentPath: docPath) { error, data in
                if let error = error {
                    completionHandler("Error fetching user data from firestore: \(error)")
                } else {
                    self.userDefaultsManager.setItemToUserDefaults(key: Constants.UserDefaults.CURRENT_USER_NAME, data: data!["name"])
                    self.saveDefaultAppSettingsToUserDefaults()
                    self.saveUserEmailToKeychain(data!["email"] as! String) { error in
                        if let error = error {
                            completionHandler("Error saving email to keychain: \(error)")
                        } else {
                            completionHandler(nil)
                        }
                    }
                }
            }
        } else {
            completionHandler("Couldn't find current user uid")
        }
    }
    
    
    func logUserToApp(email: String, password: String, completionHandler: @escaping (String?) -> ()) {

        firebaseAuthManager.loginUser(email: email, password: password) { error in
            var errorDescription = ""
            if let error = error {
                if error.contains("There is no user record") {
                    errorDescription = "Couldn't find a match to given credentials"
                } else if error.contains("The password is invalid") {
                    errorDescription = "Incorrect password"
                } else {
                    errorDescription = error
                }
                completionHandler("Unexpected error signing in: \(errorDescription)")
            } else {
                self.fetchCurrentUserDetails() { error in
                    if let error = error {
                        completionHandler("Error fetching user details: \(error)")
                    } else {
                        completionHandler(error)
                    }
                }
            }
        }
    }
    
    func fetchUserDetails(completionHandler: @escaping (String?, String?, NSData?) -> ()) {
        var name: String? = nil
        var email: String? = nil
        var picture: NSData? = nil
        
        if userDefaults.checkIfKeyExists(key: "CURRENT_USER_NAME") {
           name = userDefaults.fetchStringFromUserDefaults(key: "CURRENT_USER_NAME")
        }
        
        // TO DO : fetch email
        
        if userDefaults.checkIfKeyExists(key: "CURRENT_USER_PICTURE") {
            picture = userDefaults.fetchNSDataFromUserDefaults(key: "CURRENT_USER_PICTURE")
        }
        
        completionHandler(name, email,picture)
    }
    
    func updateUserEmail(to email: String) {
        // update in FIREBASE
        // update in UserDefaults?
    }
    
    func updateUserName(to name: String) {
        userDefaults.setItemToUserDefaults(key: "CURRENT_USER_NAME", data: name)
    }
    
<<<<<<< HEAD
    func updateUserPicture(to picture: Data?) {
        userDefaults.setItemToUserDefaults(key: "CURRENT_USER_PICTURE", data: picture)
=======
    func signUserToApp(email: String, password: String, completionHandler: @escaping (String?) -> ()) {
        firebaseAuthManager.signupUser(email: email, password: password) {error, userName, userUID in
            if let error = error {
                completionHandler("Error signing up to firebase: \(error)")
            } else {
                self.userDefaultsManager.setItemToUserDefaults(key: Constants.UserDefaults.CURRENT_USER_UID, data: userUID)
                self.userDefaultsManager.setItemToUserDefaults(key: Constants.UserDefaults.CURRENT_USER_NAME, data: userName)
                self.saveDefaultAppSettingsToUserDefaults()
                self.saveUserEmailToKeychain(email) { error in
                    if let error = error {
                        completionHandler("======== Error saving email to keychain: \(error)")
                    } else {
                        completionHandler(nil)
                    }
                }
            }
        }
    }
    
    
    func isValidEmailAddress(_ email: String) -> Bool {
        var isValidEmail = true
        let emailRegex = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        do {
            let regex = try NSRegularExpression(pattern: emailRegex)
            let nsString = email as NSString
            let results = regex.matches(in: email, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0
            {
                isValidEmail = false
            }
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            isValidEmail = false
        }
        return  isValidEmail
    }
    
    
    func isStrongPassword(_ password: String) -> Bool {
        var isStrongPassword = true
        //Minimum 8 characters - at least 1 Uppercase, 1 Lowercase, 1 Number, 1 Special Character
        let strongPasswoedRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[d$@$!%*?&#])[A-Za-z\\dd$@$!%*?&#]{8,}"
        do {
            let regex = try NSRegularExpression(pattern: strongPasswoedRegex)
            let nsString = password as NSString
            let results = regex.matches(in: password, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0
            {
                isStrongPassword = false
            }
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            isStrongPassword = false
        }
        return  isStrongPassword
    }
    
    
    private func saveUserEmailToKeychain(_ email: String, completionHandler: @escaping (String?) -> ()) {
        do {
            try self.keychainManager.addToKeychain(
                data: Data(email.utf8),
                service: Constants.Keychain.SERVICE,
                account: Constants.Keychain.ACCOUNT_USER_EMAIL,
                secClass: kSecClassGenericPassword as String
            ){
                completionHandler(nil)
            }
        } catch {
            completionHandler(error.localizedDescription)
        }
    }
    
    
    private func saveDefaultAppSettingsToUserDefaults() {
        self.userDefaultsManager.setItemToUserDefaults(key: Constants.UserDefaults.SAVE_FILTERS, data: 1)
        self.userDefaultsManager.setItemToUserDefaults(key: Constants.UserDefaults.SEND_NOTIFICATIONS, data: 1)
        self.userDefaultsManager.setItemToUserDefaults(key: Constants.UserDefaults.SAVE_SEARCH_RESULTS, data: 1)
>>>>>>> 8df7f0343a278ba6946beb2eeb3c66be3ff4862f
    }
}
