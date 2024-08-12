//
//  SheetViewModel.swift
//  AimTask
//
//  Created by Vilayath Mohammed on 2/8/2024.
//

import SwiftUI

class ListViewModel: ObservableObject {
    @Published var taskItems: [AimTask] = [
        AimTask( text: "List item 0", letter: "A"),
        AimTask( text: "List item 1", letter: "B"),
        AimTask( text: "List item 2", letter: "C")
    ]
}
