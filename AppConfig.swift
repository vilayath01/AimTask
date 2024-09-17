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
        return Bundle.main.object(forInfoDictionaryKey: "Secret email public") as? String ?? "911f773145b6ff6c1de8d26e67eecf92"
    }
    
    var secretApiEmailPrivateKey : String {
        return Bundle.main.object(forInfoDictionaryKey: "Secret email private") as? String ?? "39256f7beabf58cfc1180a5d21db199c"
    }
}
