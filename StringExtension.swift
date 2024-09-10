//
//  StringExtension.swift
//  AimTask
//
//  Created by Vilayath Mohammed on 12/8/2024.
//

import Foundation

import SwiftUI

extension String {

    // Trims everything after the '@' symbol to extract username from email
    func usernameFromEmail() -> String {
        if let atIndex = self.firstIndex(of: "@") {
            return String(self[..<atIndex])
        }
        return self
    }
    
    // Checks if the string is a valid email
    func isValidEmail() -> Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: self)
    }

    // Checks if the string contains only numbers
    func isNumeric() -> Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }

    // Trims whitespaces and newlines from both ends of the string
    func trimmed() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // Capitalizes the first letter of the string
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    // Converts a string to a URL (optional)
    func toURL() -> URL? {
        return URL(string: self)
    }
    
    // Safely access a character at a specific index
    subscript(i: Int) -> Character? {
        guard i >= 0 && i < self.count else { return nil }
        return self[index(startIndex, offsetBy: i)]
    }
    
    // Converts string to localized version
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    
}

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

func styledText(_ text: String, fontSize: CGFloat = 24, isBold: Bool = true, textColor: Color = .black) -> some View {
    Text(text)
        .font(.custom("Avenir", size: fontSize))
        .fontWeight(isBold ? .bold : .semibold)
        .foregroundColor(textColor)
}

