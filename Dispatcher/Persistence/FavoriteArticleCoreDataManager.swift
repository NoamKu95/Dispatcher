import UIKit
import CoreData

class FavoriteArticleCoreDataManager: BaseCoreDataManager {
    
    func saveArticleToCoreData(_ article: Article, completionHandler: @escaping (String?, FavoriteArticle?) -> ()) {
        let favorite = adaptArticleToFavoriteArticle(article)
        if let error = saveCoreDataChanges() {
            completionHandler(error, nil)
        } else {
            completionHandler(nil, favorite)
        }
    }
    
    
    func saveFavoriteArticlesArrayToCoreData(articles: [FavoriteArticle], completionHandler: @escaping (String?) -> ()) {
        if let error = saveCoreDataChanges() {
            completionHandler(error)
        } else {
            completionHandler(nil)
        }
    }
    
    
    func fetchFavoritesArrayFromCoreData() -> [FavoriteArticle] {
        
        let request: NSFetchRequest<FavoriteArticle> = FavoriteArticle.fetchRequest()
        do {
            let favoritesArray = try context.fetch(request)
            return favoritesArray
        } catch {
            print("Error fetching data from context, \(error)")
        }
        return []
    }
    
    
    func deleteFromCoreData(removeID: String, fromArray dataArray: [FavoriteArticle], completionHandler: @escaping (String?) -> ()) {

        var index: Int = -1
        for (i,item) in dataArray.enumerated() {
            if item.id == removeID {
                index = i
            }
        }
        if index != -1 {
            context.delete(dataArray[index])
            if let error = saveCoreDataChanges() {
                completionHandler(error)
            } else {
                completionHandler(nil)
            }
        } else {
            completionHandler("Couldn't find article id in given array")
        }
    }
    
    
    private func adaptArticleToFavoriteArticle(_ article: Article) -> FavoriteArticle {
        
        let favoriteArticle = FavoriteArticle(context: context)
        favoriteArticle.id = article.id
        favoriteArticle.isFavorite = article.isFavorite
        favoriteArticle.imageUrl = article.imageUrl
        favoriteArticle.topic = article.topic
        favoriteArticle.author = article.author
        favoriteArticle.content = article.content
        favoriteArticle.url = article.url
        favoriteArticle.date = article.date
        favoriteArticle.title = article.articleTitle
        favoriteArticle.timestamp = Date()
        
        return favoriteArticle
    }
}
