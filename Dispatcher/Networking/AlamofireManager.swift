import Foundation
import Alamofire

class AlamofireManager: NSObject {

    var url: String!
    var headers = HTTPHeaders()
    var parameters = Parameters()
    let encoding: ParameterEncoding = JSONEncoding.default
    
    
    init( data: [String:Any]? = nil, from url: String) {
        super.init()
        
        self.url = url
        ["Accept": "application/json", "Content-type": "application/json", "x-api-key": Constants.Keys.NEWS_API_KEY].forEach({ self.headers.add(name: $0.key, value: $0.value) })
        if let safeData = data {
            safeData.forEach{ parameters.updateValue($0.value, forKey: $0.key) }
        }
    }
    
    
    func executeGetQuery<T>(completionHandler: @escaping (Result<T, Error>, String?) -> Void) where T: Codable {
        AF.request(url, method: .get, headers: headers).responseData(completionHandler: { response in
            do {
                switch response.result {
                case .success:
                    completionHandler(.success(try JSONDecoder().decode(T.self, from: response.data ?? Data())), nil)
                case .failure(let error):
                    completionHandler(.failure(error), "Alamofire couldn't get the data from api")
                }
            } catch let error {
                completionHandler(.failure(error), "Alamofire failed fetching action")
            }
        })
    }
    
    
    func executePostQuery<T>(completion: @escaping (Result<T, Error>) -> Void) where T: Codable {
        AF.request(url, method: .post, parameters: parameters, encoding: encoding, headers: headers).responseData(completionHandler: { response in
            do {
                switch response.result {
                case .success:
                    completion(.success(try JSONDecoder().decode(T.self, from: response.data ?? Data())))
                case .failure(let error):
                    completion(.failure(error))
                }
            } catch let error {
                print(error)
            }
        })
    }
}
