//
//  StringExtension.swift
//  AimTask
//
//  Created by Vilayath Mohammed on 12/8/2024.
//

import Foundation


extension String {
    
    
    // Trims everything after the '@' symbol
    
    func usernameFromEmail() -> String {
        if let atIndex = self.firstIndex(of: "@") {
            return String(self[..<atIndex])
        }
        return self
    }

}
