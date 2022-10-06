import UIKit
import CoreData

enum PageSizeForFetching {
    case articlesList
    case savedArticles
}

class BaseArticlesRepository {
    
    let userDefaultsManager = UserDefaultsManager()
    let coreDataManager = FavoriteArticleCoreDataManager()
    let firestoreManager = FirestoreManager()
    let firebaseAuthManager = FirebaseAuthManager()
    
    
    func fetchNewsFromAPI(searchWords: String, pageSizeType: PageSizeForFetching, savedArticles: [String:FavoriteArticle], currentPage: Int, completionHandler: @escaping ([Article]?, Int?, String?) -> ()) {
        var pageSize: Int
        switch pageSizeType {
        case .articlesList:
            pageSize = Constants.pageSizeToFetch.ARTICLES_LIST
        case .savedArticles:
            pageSize = Constants.pageSizeToFetch.SAVED_ARTICLES
        }
        
        var cleanSearchWords = searchWords.lowercased()
        let removeCharacters: Set<Character> = [".", "\"", ",", "?", "!", "@", "#", "$", "%", "^", "&", "*"]
        cleanSearchWords.removeAll(where: { removeCharacters.contains($0) } )
        let urlEncodedSearchWords = cleanSearchWords.addingPercentEncoding(withAllowedCharacters: .alphanumerics)
        let url = "\(Constants.apiCalls.NEWS_URL)?q=\(urlEncodedSearchWords ?? cleanSearchWords)&page_size=\(pageSize)&page=\(currentPage)"
        let alamofireQuery = AlamofireManager(from: url)
            alamofireQuery.executeGetQuery() {
                ( response: Result<ArticleApiObject,Error>, statusMsg ) in
                switch response {
                case .success(let dataResult):
                    
                    var articles: [Article] = []
                    for article in dataResult.articles {
                        var article = Article(id: article.id, articleTitle: article.articleTitle, date: article.date, url: article.url, content: article.content, author: article.author, topic: article.topic, imageUrl: article.imageUrl, isFavorite: false)
                        if savedArticles[article.id] != nil {
                            article.isFavorite = true
                        }
                        articles.append(article)
                    }
                    completionHandler(articles, dataResult.totalPages, statusMsg) // ([Article], totalPages, nil)
                    
                case .failure(let error):
                    completionHandler(nil, nil, error.localizedDescription) // (nil, nil, errorText)
                }
            }
    }
    

    func getSavedArticles(completionHandler: @escaping ([String:FavoriteArticle]) -> ()) {
        
        let favoritesArray = coreDataManager.fetchFavoritesArrayFromCoreData()
        if favoritesArray.count != 0 {
            let favoritesDictionary = favoritesArray.reduce(into: [String:FavoriteArticle]()) {
                $0[$1.id!] = $1
            }
            completionHandler(favoritesDictionary)
            
        } else {
            let uid = firebaseAuthManager.getCurrentUserUID()
            if uid == nil {
                print("Error - Couldn't get current user's uid")
                completionHandler([:])
            } else {
                let colPath = "\(Constants.Firestore.USERS_COLLECTION)/\(uid!)/\(Constants.Firestore.FAVORITES_COLLECTION)"
                firestoreManager.fetchCollectionDataFromFirestore(collectionPath: colPath) { error, dataDictionary in
                    if error != nil {
                        print("Error fetching saved articles from firestore")
                        completionHandler([:])
                    } else {
                        var savedArticles: [String: FavoriteArticle] = [:]
                        for item in dataDictionary! {
                            let dict = item.value as! [String:String]
                            let favoriteArticle = FavoriteArticle(context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
                            favoriteArticle.title =  dict[Constants.FirestoreProperties.TITLE]
                            favoriteArticle.isFavorite = true
                            favoriteArticle.author = dict[Constants.FirestoreProperties.AUTHOR]
                            favoriteArticle.topic = dict[Constants.FirestoreProperties.TOPIC]
                            favoriteArticle.imageUrl = dict[Constants.FirestoreProperties.IMAGE_URL]
                            favoriteArticle.content = dict[Constants.FirestoreProperties.CONTENT]
                            favoriteArticle.url = dict[Constants.FirestoreProperties.URL]
                            favoriteArticle.date = dict[Constants.FirestoreProperties.DATE]
                            favoriteArticle.id = item.key
                            
                            let isoDate = "\(dict[Constants.FirestoreProperties.TIMESTAMP]!)+0000".replacingOccurrences(of: " ", with: "T")
                            let dateFormatter = DateFormatter()
                            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                            if let date = dateFormatter.date(from: isoDate) {
                                favoriteArticle.timestamp = date
                            } else {
                                favoriteArticle.timestamp = Date()
                            }
                            
                            savedArticles[item.key] = favoriteArticle
                        }

                        self.coreDataManager.saveFavoriteArticlesArrayToCoreData(articles: savedArticles.map({$0.value}).sorted(by: {$0.timestamp! > $1.timestamp!})) { error in
                            if let error = error {
                                print("Error saving all favorites to CoreData: \(error)")
                            }
                            completionHandler(savedArticles)
                        }
                    }
                }
            }
        }
    }
    
    
    func saveArticleToFavorites(_ article: Article, completionHandler: @escaping (String?, FavoriteArticle?) -> ()) {
        coreDataManager.saveArticleToCoreData(article) { error, favoriteArticle in
            if let error = error {
                completionHandler("Error saving article to CoreData: \(error)", nil)
            } else {
                let uid = self.firebaseAuthManager.getCurrentUserUID()
                let date = Date()
                let format = DateFormatter()
                format.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let timestamp = format.string(from: date)
                if uid != nil {
                    let dataDict: [String: Any] = [
                        Constants.FirestoreProperties.AUTHOR : article.author ?? "",
                        Constants.FirestoreProperties.CONTENT : article.content,
                        Constants.FirestoreProperties.DATE : article.date,
                        Constants.FirestoreProperties.IMAGE_URL: article.imageUrl ?? "",
                        Constants.FirestoreProperties.TITLE : article.articleTitle,
                        Constants.FirestoreProperties.TOPIC : article.topic,
                        Constants.FirestoreProperties.URL: article.url,
                        Constants.FirestoreProperties.TIMESTAMP: "\(timestamp)"
                    ]
                    let colPath = "\(Constants.Firestore.USERS_COLLECTION)/\(uid!)/\(Constants.Firestore.FAVORITES_COLLECTION)"
                    self.firestoreManager.saveDocumentToFirestore(collectionPath: colPath, customID: article.id, dataDictionary: dataDict) { error in
                        if let error = error {
                            completionHandler("Error saving into user's favorites in firestore: \(error)", nil)
                        } else {
                            completionHandler(nil, favoriteArticle)
                        }
                    }
                } else {
                    completionHandler("Couldn't get current user's uid", nil)
                }
            }
        }
    }
    
    
    func removeArticleFromFavorites(withID articleID: String, from savedArticles: [FavoriteArticle], completionHandler: @escaping (String?) -> ()) {
        coreDataManager.deleteFromCoreData(removeID: articleID, fromArray: savedArticles) { error in
            if let error = error {
                completionHandler("Error removing from CoreData: \(error)")
            } else {
                let uid = self.firebaseAuthManager.getCurrentUserUID()
                if uid != nil {
                    let docPath = "\(Constants.Firestore.USERS_COLLECTION)/\(uid!)/\(Constants.Firestore.FAVORITES_COLLECTION)/\(articleID)"
                    self.firestoreManager.removeDocumentFromCollection(documentPath: docPath) { error in
                        if let error = error {
                            completionHandler("Error removing from firestore: \(error)")
                        } else {
                            completionHandler(nil)
                        }
                    }
                } else {
                    completionHandler("Couldn't get current user's uid")
                }
            }
        }
    }
    
    
    func getUserLastLoginTimestamp() -> String? {
        return userDefaultsManager.getFromUserDefaults(key: Constants.UserDefaults.LAST_LOGIN_TIMESTAMP) as? String
    }

    func getUserAppSetting(of settingName: String) -> SwitchStatus {
        var status: SwitchStatus = .off
        switch settingName {
        case Constants.UserDefaults.SAVE_SEARCH_RESULTS:
            status = SwitchStatus(rawValue: userDefaultsManager.getFromUserDefaults(key: Constants.UserDefaults.SAVE_SEARCH_RESULTS) as? Int ?? 0) ?? .off
        case Constants.UserDefaults.SAVE_FILTERS:
            status = SwitchStatus(rawValue: userDefaultsManager.getFromUserDefaults(key: Constants.UserDefaults.SAVE_FILTERS) as? Int ?? 0) ?? .off
        case Constants.UserDefaults.SEND_NOTIFICATIONS:
            status = SwitchStatus(rawValue: userDefaultsManager.getFromUserDefaults(key: Constants.UserDefaults.SEND_NOTIFICATIONS) as? Int ?? 0) ?? .off
        default:
            print("invalid option")
        }
        return status
    }
}
