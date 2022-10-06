import Foundation

class AuthViewModel {
    
    let repository = AuthRepository()
    

    func checkIfLoggedIn() -> userType {
            if repository.checkIfLoggedIn() == .loggedIn {
                repository.fetchCurrentUserDetails() { error in
                    if let error = error {
                        print("Couldn't fetch user data - \(error)")
                        //return .loggedOut
                    }
                }
                return .loggedIn
            } else {
                return .loggedOut
            }
        }
    
    
    func logUserToApp(email: String, password: String, completionHandler: @escaping (String?) -> ()) {
        
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        repository.logUserToApp(email: cleanEmail, password: cleanPassword) { error in
            completionHandler(error)
        }
    }
    
    
    func isValidEmailAddress(email: String) -> Bool {
        return repository.isValidEmailAddress(email)
    }
    

    func isStrongPassword(password: String) -> Bool {
        return repository.isStrongPassword(password)
    }
    

    func validateSignUpFields(email: String?, password: String?, passwordAgain: String?, completionHandler: @escaping (String?, Bool) -> ()) {
        
        if let safeEmail = email, let safePassword = password, let safeAnotherPassword = passwordAgain {
            if safeAnotherPassword != safePassword {
                completionHandler("Two passwords don't match", false)
            } else if !isValidEmailAddress(email: safeEmail) {
                completionHandler("Email adress is not valid", false)
            } else if !isStrongPassword(password: safeAnotherPassword) {
                completionHandler("Password is not strong enough", false)
            } else {
                completionHandler(nil, true)
            }
        } else {
            completionHandler("One or more of the fields wasn't filled", false)
        }
    }
    
    
    func signUserToApp(email: String, password: String, completionHandler: @escaping (String?) -> ()) {
        
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        repository.signUserToApp(email: cleanEmail, password: cleanPassword) { error in
            completionHandler(error)
        }
    }
}
