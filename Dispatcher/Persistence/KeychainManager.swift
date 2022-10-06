import Foundation

enum KeychainError: Error {
    case itemNotFound
    case duplicateItem
    case invalidItemFormat
    case unexpectedStatus(OSStatus)
}

class KeychainManager {

    func fetchFromKeychain(service: String, account: String, secClass: String) throws -> Any? {

        let query: [String: AnyObject] = [
                kSecReturnData as String: kCFBooleanTrue,
                kSecAttrService as String: service as AnyObject,
                kSecAttrAccount as String: account as AnyObject,
                kSecClass as String: secClass as AnyObject,
                kSecMatchLimit as String: kSecMatchLimitOne,
            ]

            var itemCopy: AnyObject?
            let status = SecItemCopyMatching( query as CFDictionary, &itemCopy )

            guard status != errSecItemNotFound else {
                throw KeychainError.itemNotFound
            }
            guard status == errSecSuccess else {
                throw KeychainError.unexpectedStatus(status)
            }
            guard let data = itemCopy else {
                throw KeychainError.invalidItemFormat
            }

            return data
    }
    
    
    func addToKeychain(data: Data, service: String, account: String, secClass: String, completionHandler: @escaping () -> ()) throws {
        
        let query: [String: AnyObject] = [
            kSecValueData as String: data as AnyObject,
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecClass as String: secClass as AnyObject,
        ]

        let status = SecItemAdd( query as CFDictionary, nil )
        
        guard status != errSecDuplicateItem else {
            throw KeychainError.duplicateItem
        }
        
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
        
        completionHandler()
    }

    
    func updateInKeychain(data: Data, service: String, account: String, secClass: String, completionHandler: @escaping () -> ()) throws {
        
        let query: [String: Any] = [kSecClass as String: secClass as AnyObject,
                                    kSecAttrService as String: service as AnyObject]
        let attributes: [String: Any] = [kSecAttrAccount as String: account,
                                         kSecValueData as String: data as AnyObject]

        let status = SecItemUpdate( query as CFDictionary, attributes as CFDictionary )
        
        
        guard status != errSecItemNotFound else
        {
            throw KeychainError.itemNotFound
            
        }
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
        
        completionHandler()
    }
    
    
    func removeFromKeychain(service: String, account: String, secClass: String, completionHandler: @escaping () -> ()) throws {
        
        let query: [String: AnyObject] = [
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecClass as String: secClass as AnyObject
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
        
        completionHandler()
    }
}
