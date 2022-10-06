import Foundation
import Firebase
import FirebaseFirestore

class FirestoreManager {

    let database = Firestore.firestore()
    

    func saveDocumentToFirestore(collectionPath: String, customID:String, dataDictionary:[String:Any], completionHandler: @escaping (String?) -> ()) {
        let colRef = database.collection(collectionPath)
        colRef.document(customID).setData(dataDictionary) { error in
            if let error = error {
                completionHandler("Error writing document in firestore: \(error)")
            } else {
                completionHandler(nil)
            }
        }
    }
    
    
    func fetchDocumentFromFirestore(documentPath: String, completionHandler: @escaping (String?, [String : Any]?) -> ()) {
        let docRef = database.document(documentPath)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let documentValue = document.data()
                completionHandler(nil, documentValue)
            } else {
                completionHandler("Document does not exist", nil)
            }
        }
    }
    

    func fetchCollectionDataFromFirestore(collectionPath: String, completionHandler: @escaping(String?,[String : Any]?) -> ()) {
        let docRef = database.collection(collectionPath)
        docRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                completionHandler("Error getting documents: \(error)", nil)
            } else {
                var resultsDictionary: [String: Any] = [:]
                for document in querySnapshot!.documents {
                    resultsDictionary[document.documentID] = document.data()
                }
                completionHandler(nil, resultsDictionary)
            }
        }
    }
    
    
    func updateDocumentInFirestore(docuemntPath: String, property: String, value: Any, completionHandler: @escaping (String?) -> ()) {
        let docRef = database.document(docuemntPath)
        docRef.updateData([
            property: value
        ]) { error in
            if let error = error {
                completionHandler("Error updating document: \(error)")
            } else {
                completionHandler(nil)
            }
        }
    }
    

    func removeDocumentFromCollection(documentPath: String, completionHandler: @escaping(String?) -> ()) {
        let docRef = database.document(documentPath)
        docRef.delete() { error in
            if let error = error {
                completionHandler("Error removing doc from collection: \(error)")
            } else {
                completionHandler(nil)
            }
        }
    }
}
