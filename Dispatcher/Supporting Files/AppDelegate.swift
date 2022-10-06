import UIKit
import Firebase
import FirebaseCrashlytics
import FirebaseMessaging
import CoreData
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { success, error in
            guard success else {
                print("error occured: \(error?.localizedDescription)")
                return
            }
            print("Success in APNS registry")
        }
        application.registerForRemoteNotifications()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        //Save changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    
}

extension AppDelegate : UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        print("Func is called after it successfully registered the app with APNs")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register with push")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Got notification in FOREGROUND")
        handleIncomingNotification(notification) {
            completionHandler([.alert, .sound, .badge]) // defines how to notify the user
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Func gets called when user taps on the notification to open it")
        completionHandler()
    }
    
    func handleIncomingNotification(_ notification: UNNotification, completionHandler: @escaping () -> ()) {
        let firestoreManager = FirestoreManager()
        let firebaseAuthManager = FirebaseAuthManager()

        // Save notification to Firestore
        let uid = firebaseAuthManager.getCurrentUserUID()
        if let uid = uid {
            let dataDict: [String: Any] = [
                //Notification Data
                "notificationDate": notification.date,
                "notificationContent": notification.request.content.body,
                "notificationTitle": notification.request.content.title,
                "wasRead": false,
                //Article Data
                "articleID": notification.request.content.userInfo["articleID"] ?? nil,
                "articleAuthor": notification.request.content.userInfo["articleAuthor"] ?? nil,
                "articleContent": notification.request.content.userInfo["articleContent"] ?? nil,
                "articleDate": notification.request.content.userInfo["articleDate"] ?? nil,
                "articleImageUrl": notification.request.content.userInfo["articleImageUrl"] ?? nil,
                "articleTitle": notification.request.content.userInfo["articleTitle"] ?? nil,
                "articleTopic": notification.request.content.userInfo["articleTopic"] ?? nil,
                "articleURL": notification.request.content.userInfo["articleURL"] ?? nil,
            ]
            let colPath = "\(Constants.Firestore.USERS_COLLECTION)/\(uid)/\(Constants.Firestore.NOTIFICATIONS_COLLECTION)"
            firestoreManager.saveDocumentToFirestore(collectionPath: colPath, customID: notification.request.identifier, dataDictionary: dataDict) { error in
                if let error = error {
                    print("Error saving notification to firestore: \(error)")
                } else {
                    print("Success saving notification to firestore")
                    
                    //Update notifications icon so user is aware
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationCenter.NOTIFICATION_RECIVED), object: nil)
                    
                    completionHandler()
                }
            }
        }
    }
}

extension AppDelegate : MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        messaging.token { token, error in
            guard let token = token else {
                return
            }
            print("token: \(token)")
        }
    }
}
