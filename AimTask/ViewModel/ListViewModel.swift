//
//  SheetViewModel.swift
//  AimTask
//
//  Created by Vilayath Mohammed on 2/8/2024.
//

import SwiftUI

class ListViewModel: ObservableObject {
    @Published var taskItems: [AddTaskModel] = [
        AddTaskModel(locationName: "Smaple", dateTime: Date(), taskItems: ["Example"])
    ]
}
