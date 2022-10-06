//
//  NotificationsRepository.swift
//  Dispatcher
//
//  Created by Noam Kurtzer on 22/06/2022.
//

import Foundation

class NotificationsRepository {
    
    let firestoreManager = FirestoreManager()
    let firebaseAuthManager = FirebaseAuthManager()
    
    func fetchNotificationsFromFirestore(completionHandler: @escaping (String?, [NotificationModel]) -> ()) {
        let uid = firebaseAuthManager.getCurrentUserUID()
        if let uid = uid {
            let colPath = "\(Constants.Firestore.USERS_COLLECTION)/\(uid)/\(Constants.Firestore.NOTIFICATIONS_COLLECTION)"
            firestoreManager.fetchCollectionDataFromFirestore(collectionPath: colPath) { error, dataDictionary in
                if error != nil {
                    completionHandler("Error fetching notifications from firestore", [])
                } else {
                    var notificationsArray: [NotificationModel] = []
                    for item in dataDictionary! {
                
                        let dict = item.value as! [String:Any]
                        // Create the notification
                        var notification = NotificationModel(
                            text: dict["notificationContent"] as? String ?? "notification text",
                            wasRead: dict["wasRead"] as? Bool ?? false,
                            id: item.key,
                            date: dict["notificationDate"] as? String ?? "notification date",
                            article: nil
                        )
                        // If it's article related - Add the article
                        if dict["articleID"] as? String != "" && dict["articleID"] != nil {
                            notification.article = Article(
                                id: dict["articleID"] as? String ?? "-1",
                                articleTitle: dict["articleTitle"] as? String ?? "article title",
                                date: dict["articleDate"] as? String ?? "article date",
                                url: dict["articleURL"] as? String ?? "article url",
                                content: dict["articleContent"] as? String ?? "article content",
                                author: dict["articleAuthor"] as? String ?? "article author",
                                topic: dict["articleTopic"] as? String ?? "topic",
                                imageUrl: dict["articleImageURL"] as? String ?? "article image url",
                                isFavorite: false
                            )
                        }
                        
                        notificationsArray.append(notification)
                    }
                    
                    completionHandler(nil, notificationsArray)
                }
            }
        }
        
    }
    
    func setNotificationAsRead(_ notificationID: String, completionHandler: @escaping (String?) -> ()) {
        let uid = firebaseAuthManager.getCurrentUserUID()
        if let uid = uid {
            let docPath = "\(Constants.Firestore.USERS_COLLECTION)/\(uid)/\(Constants.Firestore.NOTIFICATIONS_COLLECTION)/\(notificationID)"
            firestoreManager.updateDocumentInFirestore(docuemntPath: docPath, property: Constants.FirestoreProperties.WAS_READ, value: true) { error in
                completionHandler(error)
            }
        } else {
            completionHandler("couldn't get user's id")
        }
    }
}
