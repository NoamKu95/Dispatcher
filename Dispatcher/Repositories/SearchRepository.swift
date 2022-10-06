import Foundation

class SearchRepository: BaseArticlesRepository {
    
    let userDefaults = UserDefaultsManager()
    
    
    func getSavedRecentSearchesFromUserDefaults() -> [String]? {
        return userDefaults.getArrayFromUserDefaults(key: Constants.UserDefaults.RECENT_SEARCHES)
    }
    
    
    func updateRecentSearchesInUserDefaults(recentSearchesArr: [RecentSearchModel]) {
        var recentSearchesStringsArray: [String] = []
        for search in recentSearchesArr {
            recentSearchesStringsArray.append(search.text)
        }
        userDefaults.setArrayToUserDefaults(key: Constants.UserDefaults.RECENT_SEARCHES, dataArray: recentSearchesStringsArray)
    }
}
