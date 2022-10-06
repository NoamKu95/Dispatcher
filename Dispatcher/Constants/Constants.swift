import Foundation

struct Constants {
    
    struct ScreenNames {
        static let HOMEPAGE = "Homepage"
        static let PROFILE = "Profile"
        static let FAVORITES = "Favorites"
        static let SETTINGS = "Setting"
        static let PRIVACY = "Terms & privacy"
        static let LOGOUT = "Logout"
    }
    
    struct ButtonsText {
        static let LOGIN = "LOGIN"
        static let SIGNUP = "SIGNUP"
        static let LOGOUT = "LOGOUT"
        static let OK = "OK"
    }
    
    struct TextFieldsIDs {
        //Signup
        static let EMAIL = "email"
        static let PASSWORD = "password"
        static let PASSWORD_AGAIN = "re-password"
        //User profile
        static let NAME = "name"
        static let USRE_EMAIL = "userEmail"
    }
    
    struct Segues {
        static let HOMEPAGE_TO_ARTICLE = "homepageToArticle"
        static let FAVORITES_TO_ARTICLE = "favoritesToArticle"
        static let HOMEPAGE_TO_NOTIFICATIONS = "homepageToNotifications"
        static let HOMEPAGE_TO_SEARCH = "homepageToSearch"
        static let FAVORITES_TO_NOTIFICATIONS = "favoritesToNotifications"
        static let FAVORITES_TO_SEARCH = "favoritesToSearch"
        static let SEARCH_TO_ARTICLE = "searchToArticle"
        static let NOTIFICATIONS_TO_ARTICLE = "notificationsToArticle"
        static let GO_TO_UPDATE_PROFILE = "goToUpdateProfile"
        static let GO_TO_TERMS_AND_PRIVACY = "goToTermsAndPrivacy"
        static let GO_TO_SETTINGS = "goToSettings"
        static let SPLASH_TO_AUTH = "splashToAuth"
    }
    
    struct TableCellsIdentifier {
        static let NOTIFICATION = "notificationCell"
        static let FAVORITES = "savedArticleCell"
        static let HOMEPAGE = "newsCell"
        static let PROFILE_OPTION = "ProfileOptionCell"
        static let SETTING = "AppSettingCell"
        static let SETTING_SECTION = "SettingSectionCell"
        static let RECENT_SEARCH = "RecentSearchCell"
    }
    
    struct NibNames {
        static let HOMEPAGE = "NewsCell"
        static let FAVORITES = "SavedArticleCell"
        static let NOTIFICATION = "NotificationCell"
        static let PROFILE_OPTION = "ProfileOptionCell"
        static let APP_SETTING = "AppSettingCell"
        static let APP_SETTING_SECTION = "SettingSectionCell"
        static let RECENT_SEARCH = "RecentSearchCell"
    }
    
    struct AppSettingsSectionTitles {
        static let SEARCH = "Search results"
        static let PREFERENCES = "App preferences"
    }
    
    struct AppSettings {
        static let SAVE_FILTERS = "Save filters"
        static let SEARCH_RESULTS = "Save search results"
        static let NOTIFICATION = "Notification"
    }
    
    struct NotificationCenter {
        static let HOMEPAGE_TO_FAVORITES = "favoritesChangedInHomepageNotif"
        static let FAVORITES_TO_HOMEPAGE = "favoritesChangedInFavoritesNotif"
        static let ARTICLE_TO_TABLES = "articleChangedSoUpdateTableViews"
        static let PICTURE_UPDATE = "userIconImageChanged"
        static let RECENT_SEARCHES_EMPTIED = "recentSearchesClearedInUserDefaults"
        
        static let ARTICLE_ID = "articleID"
        static let IS_FAVORITE = "isFavorite"
        
        static let SENDER = "senderViewController"
        static let SENDER_FAVORITES = "FavoritesViewController"
        static let SENDER_ARTICLE = "ArticleViewController"
        
        static let NOTIFICATION_RECIVED = "notificationRecived"
        static let NO_MORE_NOTIFICATIONS = "noNotificationsLeft"
    }
    
    struct UserDefaults {
        static let RECENT_SEARCHES = "recentSearches"
        
        static let SAVE_FILTERS = "saveFilters"
        static let SAVE_SEARCH_RESULTS = "saveSearchResults"
        static let SEND_NOTIFICATIONS = "sendNotifications"
        
        static let CURRENT_USER_UID = "currentUserUID"
        static let CURRENT_USER_NAME = "currentUserName"
        static let CURRENT_USER_IMAGE = "currentUserImage"
        static let LAST_LOGIN_TIMESTAMP = "lastTimeUserLoggedIntoApp"
    }
    
    struct Keychain {
        static let SERVICE = "dispatcher.moveo"
        static let ACCOUNT_USER_EMAIL = "currentUserEmail"
    }
    
    struct Firestore {
        static let USERS_COLLECTION = "Users"
        static let FAVORITES_COLLECTION = "savedArticles"
        static let NOTIFICATIONS_COLLECTION = "notifications"
    }
    
    struct FirestoreProperties {
        static let NAME = "name"
        static let IMAGE = "image"
        static let EMAIL = "email"
        static let AUTHOR = "author"
        static let CONTENT = "content"
        static let DATE = "date"
        static let IMAGE_URL = "imageUrl"
        static let TITLE = "title"
        static let TOPIC = "topic"
        static let URL = "url"
        static let TIMESTAMP = "timestamp"
        static let WAS_READ = "wasRead"
    }
    
    struct apiCalls {
        static let NEWS_URL = "https://api.newscatcherapi.com/v2/search"
    }
    
    struct pageSizeToFetch {
        static let SAVED_ARTICLES = 10
        static let ARTICLES_LIST = 7
    }
    
    struct Keys {
        static let NEWS_API_KEY = "JaLZokYWhKco80EWVUdPapZGSCgDCqrEJ6Hij1kGV-Q"
    }
}
