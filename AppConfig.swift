//
//  AppConfig.swift
//  AimTask
//
//  Created by vila on 11/9/2024.
//

import Foundation

class AppConfig {
    static let shared = AppConfig()
    
    var secretApiEmailPublicKey : String {
        return Bundle.main.object(forInfoDictionaryKey: "Secret email public") as? String ?? ""
    }
    
    var secretApiEmailPrivateKey : String {
        return Bundle.main.object(forInfoDictionaryKey: "Secret email private") as? String ?? ""
    }
}
