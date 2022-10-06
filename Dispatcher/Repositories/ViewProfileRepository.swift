import Foundation

class ViewProfileRepository {
    
    let userDefaultsManager = UserDefaultsManager()
    let keychainManager = KeychainManager()
    let firestoreManager = FirestoreManager()
    let firebaseAuthManager = FirebaseAuthManager()
    
    
    func getUserUID() -> String? {
        return firebaseAuthManager.getCurrentUserUID()
    }
    
    
    func getDataOnUser(subject dataKey: String, completionHandler: @escaping (Any?) -> ()) {
        
        switch dataKey {
        case Constants.UserDefaults.CURRENT_USER_NAME:
            completionHandler(userDefaultsManager.getFromUserDefaults(key: Constants.UserDefaults.CURRENT_USER_NAME))
            
        case Constants.TextFieldsIDs.USRE_EMAIL:
            do {
                completionHandler( try keychainManager.fetchFromKeychain(
                    service: Constants.Keychain.SERVICE,
                    account: Constants.Keychain.ACCOUNT_USER_EMAIL,
                    secClass: kSecClassGenericPassword as String
                ))
            } catch (let error) {
                print("Error getting email from keychain - \(error)")
                completionHandler(nil)
            }
            
        case Constants.UserDefaults.CURRENT_USER_IMAGE:
            completionHandler(userDefaultsManager.getFromUserDefaults(key: Constants.UserDefaults.CURRENT_USER_IMAGE))
            
        default:
            print("invalid option")
        }
    }
    
    
    func updateUserDetail(detailType: String, data: Any) {
        
        let uid = firebaseAuthManager.getCurrentUserUID()
        if let uid = uid {
            let docPath = "\(Constants.Firestore.USERS_COLLECTION)/\(uid)"
            
            switch detailType {
                
            case Constants.UserDefaults.CURRENT_USER_NAME:
                firestoreManager.updateDocumentInFirestore(docuemntPath: docPath, property: Constants.FirestoreProperties.NAME, value: data) { error in
                    if let error = error {
                        print("Faild updating name in Firestore - \(error)")
                    } else {
                        self.userDefaultsManager.setItemToUserDefaults(key: detailType, data: data)
                    }
                }
                
            case Constants.TextFieldsIDs.USRE_EMAIL:
                let email = data as! String
                firebaseAuthManager.updateUserEmail(to: email) { error in
                    if let error = error {
                        print("Faild updating email in Firebase Auth - \(error)")
                    } else {
                        self.firestoreManager.updateDocumentInFirestore(docuemntPath: docPath, property: Constants.FirestoreProperties.EMAIL, value: email) { error in
                            if let error = error {
                                print("Faild updating email in Firestore - \(error)")
                            }
                            do {
                                try self.keychainManager.updateInKeychain(
                                    data: Data(email.utf8),
                                    service: Constants.Keychain.SERVICE,
                                    account: Constants.Keychain.ACCOUNT_USER_EMAIL,
                                    secClass: kSecClassGenericPassword as String
                                ){
                                    
                                }
                            } catch (let error) {
                                print("Error updating keychain - \(error)")
                            }
                        }
                    }
                }
                
            case Constants.UserDefaults.CURRENT_USER_IMAGE:
                print("DATA to update usr IMAGE in FIRESTORE")
                print(data)
                firestoreManager.updateDocumentInFirestore(docuemntPath: docPath, property: Constants.FirestoreProperties.IMAGE, value: data) { error in
                    if let error = error {
                        print("Faild updating image in Firestore - \(error)")
                    }
                }
            default:
                print("invalide option")
            }
        } else {
            print("couldn't get current user's uid")
        }
    }
}
