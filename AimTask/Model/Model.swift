//
//  Model.swift
//  AimTask
//
//  Created by Vilayath Mohammed on 21/7/2024.
//

import Foundation
import CoreLocation
import SwiftUI

struct AimTask: Identifiable {
    var id: String = ""
    var name: String = ""
    var location: CLLocation?
    var dateTime: Date?
    var text: String = ""
    var letter: String = ""
    var isChecked: Bool = false
    var locationName: String = ""
}


struct AddTaskModel: Identifiable {
    var id: UUID = UUID()
    var locationName: String = ""
    var dateTime: Date = Date()
    var taskItems: [String]
    var coordinate: CLLocationCoordinate2D
    

    init(locationName: String, dateTime: Date, taskItems: [String] = [], coordinate: CLLocationCoordinate2D) {
        self.locationName = locationName
        self.dateTime = dateTime
        self.taskItems = taskItems
        self.coordinate = coordinate
    }
}



