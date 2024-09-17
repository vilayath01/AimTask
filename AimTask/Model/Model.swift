//
//  Model.swift
//  AimTask
//
//  Created by Vilayath Mohammed on 21/7/2024.
//

import Foundation
import CoreLocation
import SwiftUI

struct TaskModel: Identifiable {
    var id: UUID = UUID()
    var locationName: String = ""
    var addTaskDateTime: Date = Date()
    var completedTaskDateTime: Date = Date()
    var taskItems: [String]
    var coordinate: CLLocationCoordinate2D
    var documentID: String
    var enteredGeofence: Bool = false
    var saveHistory: Bool = false
    

    init(locationName: String, addTaskDateTime: Date, completedTaskDateTime: Date, taskItems: [String] = [], coordinate: CLLocationCoordinate2D, documentID: String,enteredGeofence: Bool, saveHistory: Bool ) {
        self.locationName = locationName
        self.addTaskDateTime = addTaskDateTime
        self.completedTaskDateTime = completedTaskDateTime
        self.taskItems = taskItems
        self.coordinate = coordinate
        self.documentID = documentID
        self.enteredGeofence = enteredGeofence
        self.saveHistory = saveHistory
    }
}



