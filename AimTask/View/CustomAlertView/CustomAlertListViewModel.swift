//
//  SheetViewModel.swift
//  AimTask
//
//  Created by Vilayath Mohammed on 2/8/2024.
//

import SwiftUI
import CoreLocation

class CustomAlertListViewModel: ObservableObject {
    @Published var taskItems: [TaskModel] = [
        TaskModel(locationName: "", addTaskDateTime: Date(), completedTaskDateTime: Date(), taskItems: [""], coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), documentID: "", enteredGeofence: false, saveHistory: false)
    ]
}
