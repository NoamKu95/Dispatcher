import Foundation

class NotificationsViewModel {
    
    private let repository = NotificationsRepository()
    
    var notificationsArray: [NotificationModel] = []
    
    
    func fetchNotificationsFromFirestore(completionHandler: @escaping () -> ()) {
        repository.fetchNotificationsFromFirestore() { error, notificationsArray in
            if let error = error {
                print(error)
            } else {
                self.notificationsArray = notificationsArray
                completionHandler()
            }
        }
    }
    
    func setNotificationAsRead(byID notificationID: String, completionHandler: @escaping (String?, Bool) -> ()) {
        repository.setNotificationAsRead(notificationID) { error in
            if let error = error {
                completionHandler(error, true)
            } else {
                let index = self.notificationsArray.firstIndex(where: { $0.id == notificationID })
                if let index = index {
                    self.notificationsArray[index].wasRead = true
                    let moreUnreadNotifications = self.notificationsArray.contains(where: { $0.wasRead == false })
                    completionHandler(nil, moreUnreadNotifications)
                } else {
                    completionHandler("couldn't find notification in array", true)
                }
            }
        }
    }
    
}
