//
//  SheetViewModel.swift
//  AimTask
//
//  Created by Vilayath Mohammed on 2/8/2024.
//

import SwiftUI

class ListViewModel: ObservableObject {
    @Published var items: [ListItem] = [
        ListItem( text: "List item 0", letter: "A"),
        ListItem( text: "List item 1", letter: "B"),
        ListItem( text: "List item 2", letter: "C")
    ]
}
