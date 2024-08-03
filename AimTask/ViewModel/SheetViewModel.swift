//
//  SheetViewModel.swift
//  AimTask
//
//  Created by Vilayath Mohammed on 2/8/2024.
//

import SwiftUI

class ListViewModel: ObservableObject {
    @Published var items: [ListItem] = [
        ListItem(id: UUID(), text: "List item 0"),
        ListItem(id: UUID(), text: "List item 2"),
        ListItem(id: UUID(), text: "List item 3")
    ]
}
