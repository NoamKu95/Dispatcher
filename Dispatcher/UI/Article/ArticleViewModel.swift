import Foundation

class ArticleViewModel {
    
    let repository = BaseArticlesRepository()
    var savedArticles: [String:FavoriteArticle] = [:]
    
    
    func getSavedArticles(completionHandler: @escaping () -> ()) {
        repository.getSavedArticles() { articlesArray in
            self.savedArticles = articlesArray
            completionHandler()
        }
    }
    
    
    func removeArticleFromFavorites(articleID: String, completionHandler: @escaping () -> ()) {
        getSavedArticles {
            // remove from CoreData + Firestore
            self.repository.removeArticleFromFavorites(withID: articleID, from: self.savedArticles.map({$0.value})) { error in
                if let error = error {
                    print(error)
                } else {
                    completionHandler()
                }
            }
        }
    }
    
    
    func addArticleToFavorites(newArticle: Article , completionHandler: @escaping () -> ()) {
        repository.saveArticleToFavorites(newArticle) { error, _ in
            if let error = error {
                print(error)
            } else {
                completionHandler()
            }
        }
        
    }
}
