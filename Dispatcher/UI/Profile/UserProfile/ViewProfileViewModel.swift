import Foundation

class ViewProfileViewModel: AuthViewModel {
    
    let vpRepository = ViewProfileRepository()
    
    
    func getUserUID() -> String? {
        return vpRepository.getUserUID()
    }
    
    
    func getDataOnUser(subject dataKey: String, completionHandler: @escaping (Any?) -> ()) {
        vpRepository.getDataOnUser(subject: dataKey) { data in
            completionHandler(data)
        }
    }
    
    
    func updateUserDetail(detailType: String, data: Any) {
        return vpRepository.updateUserDetail(detailType: detailType, data: data)
    }
}
