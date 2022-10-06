import Foundation

struct ArticleApiObject: Codable {
    
    let totalPages: Int
    let articles: [ArticleResponse]
    let numOfResults: Int
    
    enum CodingKeys: String, CodingKey {
        case totalPages = "total_pages"
        case articles = "articles"
        case numOfResults = "total_hits"
    }
}

struct ArticleResponse: Codable {
    
    let id: String
    let articleTitle: String
    let date: String
    let url: String
    let content: String
    let author: String?
    let topic: String
    let imageUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case articleTitle = "title"
        case content = "summary"
        case author = "author"
        case url = "link"
        case date = "published_date"
        case topic = "topic"
        case imageUrl = "media"
    }
}
