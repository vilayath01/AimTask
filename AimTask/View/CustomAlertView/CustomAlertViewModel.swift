//
//  AddingViewModel.swift
//  AimTask
//
//  Created by Vilayath Mohammed on 2/8/2024.
//

import Foundation

enum CustomAlertString {
    static let addTaskItem = "add_task_item"
    static let cancel = "cancel"
    static let save = "save"
    static let listItem = "list_item"
    static let listItemPlaceholder = "list_item_placeholder"
    
    static func localized(_ key: String, _ arguments: CVarArg...) -> String {
        let formatString = NSLocalizedString(key, comment: "")
        return String(format: formatString, arguments: arguments)
    }
}


class CustomAlertViewModel: ObservableObject {
    
    @Published  var addTaskModel: [TaskModel] = []
        
    func addItem(to items: inout [String]) {
            let newItem = ""
            items.append(newItem)
        }
    
    func removeItem(at index: Int, from items: inout [String]) {
        guard index >= 0 && index < items.count else { return }
        items.remove(at: index)
    }
    
    func removeAllButOneItem(from items: inout [String]) {
    
        items = [""]
    }

}
