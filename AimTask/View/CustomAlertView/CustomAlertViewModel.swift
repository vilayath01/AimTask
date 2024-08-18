//
//  AddingViewModel.swift
//  AimTask
//
//  Created by Vilayath Mohammed on 2/8/2024.
//

import Foundation


class CustomAlertViewModel: ObservableObject {
    
    @Published  var addTaskModel: [TaskModel] = []
    
    func alphabet(for index: Int) -> String {
        var result = ""
        var currentIndex = index

        repeat {
            let unicodeValue = UnicodeScalar("A").value
            let letterIndex = Int(currentIndex % 26)
            if let scalar = UnicodeScalar(unicodeValue + UInt32(letterIndex)) {
                result = String(scalar) + result
            }
            currentIndex = (currentIndex / 26) - 1
        } while currentIndex >= 0

        return result
    }
    
    func addItem(to items: inout [String]) {
            let newItemIndex = items.count
            let newAlphabet = alphabet(for: newItemIndex)
            let newItem = "\(newAlphabet) Item"
            items.append(newItem)
        }
    
    func removeItem(at index: Int, from items: inout [String]) {
        guard index >= 0 && index < items.count else { return }
        items.remove(at: index)
    }

}
