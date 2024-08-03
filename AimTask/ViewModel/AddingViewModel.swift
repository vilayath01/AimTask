//
//  AddingViewModel.swift
//  AimTask
//
//  Created by Vilayath Mohammed on 2/8/2024.
//

import Foundation


class AddingViewModel: ObservableObject {
    
  @Published  var items: [ListItem] = []
    
    
    // A,B,C,D...
    
     func alphabet(for index: Int) -> String {
        let startingString = UnicodeScalar("A").value
        let unicode = startingString + UInt32(index % 26)
        return String(UnicodeScalar(unicode)!)
         
    }
    
    func addItem() {
        let newItemIndex = items.count
        let newAlphabet = alphabet(for: newItemIndex)
        let newItem = ListItem(id: UUID(), text: newAlphabet)
        items.append(newItem)
       }
    
     func getIndex(of id: UUID) -> Int {
           // Find the index of the item based on the UUID
           if let index = items.firstIndex(where: { $0.id == id }) {
               return index
           }
           return 0 // Default to 0 if not found
       }
}
