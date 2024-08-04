//
//  AddingViewModel.swift
//  AimTask
//
//  Created by Vilayath Mohammed on 2/8/2024.
//

import Foundation


class AddingViewModel: ObservableObject {
    
  @Published  var items: [ListItem] = []
    
    
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
    
    func addItem(to items: inout [ListItem]) {
          let newItemIndex = items.count
          let newAlphabet = alphabet(for: newItemIndex)
        let newItem = ListItem(text:"", letter: newAlphabet)
          items.append(newItem)
      }
    
    func removeItem(at index: Int, from items: inout [ListItem]) {
          guard index >= 0 && index < items.count else { return }
          items.remove(at: index)
      }
    
     func getIndex(of id: UUID) -> Int {
           if let index = items.firstIndex(where: { $0.id == id }) {
               return index
           }
           return 0
       }
}
