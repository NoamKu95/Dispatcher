import Foundation

enum userType {
    case loggedOut
    case loggedIn
}

class AuthRepository {
    
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
    
    func checkIfLoggedIn() -> userType {
        
        if firebaseManager.checkUserLogin() {
            return .loggedIn
        }
        return .loggedOut
    }
    
    func signUserToApp(email: String, password: String, completionHandler: @escaping (String?) -> ()) {
        
        firebaseManager.signupUser(email: email, password: password) { error in
            completionHandler(error)
        }
    }
    
    func logUserToApp(email: String, password: String, completionHandler: @escaping (String?) -> ()) {
        firebaseManager.loginUser(email: email, password: password) { error in
            var errorDescription = ""
            if let error = error {
                if error.contains("There is no user record") {
                    errorDescription = "Couldn't find a match to given credentials"
                } else if error.contains("The password is invalid") {
                    errorDescription = "Incorrect password"
                } else {
                    errorDescription = error
                }
                completionHandler(errorDescription)
            } else {
                completionHandler(error)
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
    
    func updateUserPicture(to picture: Data?) {
        userDefaults.setItemToUserDefaults(key: "CURRENT_USER_PICTURE", data: picture)
    }
}
