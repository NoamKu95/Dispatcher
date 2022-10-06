import Foundation

class BaseArticlesViewModel {
    
    private let repository = BaseArticlesRepository()
    
    var savedArticles: [String:FavoriteArticle] = [:]
    var keysArray : [String] = []
    var newsArray: [Article] = []
    
    private var currentPaginationPage = 1
    private var totalPaginationPages = 1
    
    
    func fetchNewsFromAPI(searchWords: String = "new", pageSizeToFetch: PageSizeForFetching, completionHandler: @escaping (String?, Int?) -> ()) {
        repository.fetchNewsFromAPI(searchWords: searchWords, pageSizeType: pageSizeToFetch, savedArticles: savedArticles, currentPage: currentPaginationPage) {
            articles, totalPages, statusMsg in
            if let statusMsg = statusMsg {
                self.newsArray = []
                completionHandler(statusMsg, nil)
            } else {
                self.currentPaginationPage += 1
                if let totalPages = totalPages {
                    self.totalPaginationPages = totalPages
                }
                self.newsArray.append(contentsOf: articles!)
                completionHandler(nil, articles?.count)
            }
        }
    }
    

    func getSavedArticles(completionHandler: @escaping () -> ()) {
        repository.getSavedArticles() { articlesArray in
            self.savedArticles = articlesArray
            self.keysArray = Array(self.savedArticles.keys)
            completionHandler()
        }
    }
    

    func getUserAppSetting(of settingName: String) -> SwitchStatus {
        return repository.getUserAppSetting(of: settingName)
    }
    
    
    func getUserLastLoginTimestamp() -> String? {
        return repository.getUserLastLoginTimestamp()
    }
    

    func addArticleToFavorites(_ article: Article, completionHandler: @escaping (String?, Int?) -> ()) {
        repository.saveArticleToFavorites(article) { error, newFavorite in
            if let error = error {
                completionHandler(error,nil)
            } else {
                self.savedArticles[article.id] = newFavorite
                self.keysArray = Array(self.savedArticles.keys)
                if self.newsArray.count == 0 {
                    completionHandler(nil,nil)
                } else {
                    if let index = self.newsArray.firstIndex(where: { $0.id == article.id }) {
                        self.newsArray[index].isFavorite = true
                        completionHandler(nil, index)
                    }
                }
            }
        }
    }
    

    func removeArticleFromFavorites(articleID: String, completionHandler: @escaping (String?, Int?) -> ()) {
        repository.removeArticleFromFavorites(withID: articleID, from: savedArticles.map({$0.value})) { error in
            if let error = error {
                completionHandler(error,nil)
            } else {
                self.updateArticleToNotFavoriteLocally(articleID: articleID) { index in
                    completionHandler(nil,index)
                }
            }
        }
    }
    
    
    func updateArticleToNotFavoriteLocally(articleID: String, completionHandler: @escaping (Int?) -> ()) {
        self.savedArticles[articleID] = nil
        self.keysArray = Array(self.savedArticles.keys)
        let index = newsArray.firstIndex(where: {$0.id == articleID}) ?? -1
        if index != -1 {
            self.newsArray[index].isFavorite = false
        }
        completionHandler(index)
    }
    
    
    func updateArticleToYesFavoriteLocally(articleID: String, completionHandler: @escaping () -> ()) {
        if let index = self.newsArray.firstIndex(where: {$0.id == articleID}) {
            self.newsArray[index].isFavorite = true
            self.keysArray = Array(self.savedArticles.keys)
            completionHandler()
        }
    }
}
