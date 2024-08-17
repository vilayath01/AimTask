//
//  SheetViewModel.swift
//  AimTask
//
//  Created by Vilayath Mohammed on 2/8/2024.
//

import SwiftUI
import CoreLocation

class CustomAlertListViewModel: ObservableObject {
    @Published var taskItems: [AddTaskModel] = [
        AddTaskModel(locationName: "Smaple", dateTime: Date(), taskItems: ["Example"], coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))
    ]
}
