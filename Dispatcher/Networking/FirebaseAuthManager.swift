import Foundation
import FirebaseAuth

class FirebaseAuthManager {
    
    let firestoreManager = FirestoreManager()
    
    
    func isUserLoggedIn() -> Bool {
        return Auth.auth().currentUser != nil
    }
    

    func getCurrentUserUID() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    func getlastUserLoginTimestamp() -> String? {
        return Auth.auth().currentUser?.metadata.lastSignInDate?.description
    }
    
    func signupUser(email: String, password: String, completionHandler: @escaping (String?, String?, String?) -> ()) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completionHandler("Failed signing up: \(error.localizedDescription)", nil, nil)
            } else {
                let uid = authResult!.user.uid
                let userName = String(email.prefix(upTo: email.firstIndex(of: "@")!))
                let dataDict: [String:Any] = [ "email": email as Any, "name": userName as Any ]
                let colPath = Constants.Firestore.USERS_COLLECTION
                
                self.firestoreManager.saveDocumentToFirestore(collectionPath: colPath, customID: uid, dataDictionary: dataDict) { error in
                    if let error = error {
                        completionHandler("Error saving registered user to firestore: \(error)", nil, nil)
                        // TO DO - remove from Firebase Auth ?
                    } else {
                        completionHandler(nil, String(userName), uid)
                    }
                }
            }
        }
    }
    
    
    func loginUser(email: String, password: String, completionHandler: @escaping (String?) -> ()) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completionHandler(error.localizedDescription)
            } else {
                completionHandler(nil)
            }
        }
    }
    
    
    func logoutUser(completionHandler: @escaping (String?) -> ()) {
        do {
            try Auth.auth().signOut()
            completionHandler(nil)
        } catch (let error) {
            completionHandler(error.localizedDescription)
        }
    }
    
    
    func updateUserEmail(to email: String, completionHandler: @escaping (String?) -> ()) {
        Auth.auth().currentUser?.updateEmail(to: email) { error in
            completionHandler(error?.localizedDescription)
        }
    }
}
