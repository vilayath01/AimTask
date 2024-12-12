//
//  KeychainHelper.swift
//  AimTask
//
//  Created by vila on 13/12/2024.
//


import Foundation

class KeychainHelper {
    static let shared = KeychainHelper()
    
    private init() {}
    
    func saveCredentials(userName: String, password: String) {
        let credentials: [String: String] = ["userName": userName, "password": password]
        if let data = try? JSONEncoder().encode(credentials) {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: "userCredentials",
                kSecValueData as String: data
            ]
            SecItemDelete(query as CFDictionary)
            SecItemAdd(query as CFDictionary, nil)
        }
    }
    
    func fetchCredentials() -> (userName: String, password: String)? {
        let query: [String: Any] = [
            
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "userCredentials",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        if SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess {
            if let data = item as? Data,
               let credentials = try? JSONDecoder().decode([String: String].self, from: data),
               let userName = credentials["userName"],
               let password = credentials["password"] {
                return (userName, password)
            }
                
        }
        return nil
    }
  
}
