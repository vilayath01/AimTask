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
    var dateTime: Date = Date()
    var taskItems: [String]
    var coordinate: CLLocationCoordinate2D
    var documentID: String
    

    init(locationName: String, dateTime: Date, taskItems: [String] = [], coordinate: CLLocationCoordinate2D, documentID: String) {
        self.locationName = locationName
        self.dateTime = dateTime
        self.taskItems = taskItems
        self.coordinate = coordinate
        self.documentID = documentID
    }
}



