import Foundation

enum userType {
    case loggedOut
    case loggedIn
}

class AuthRepository {
    
    let firebaseManager = FirebaseAuthManager()
    
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
    
    
}
