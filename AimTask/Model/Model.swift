//
//  Model.swift
//  AimTask
//
//  Created by Vilayath Mohammed on 21/7/2024.
//

import Foundation
import CoreLocation
import SwiftUI

struct Task: Identifiable {
    let id: String
    let name: String
    let location: CLLocation
    let dateTime: Date
}


struct ListItem: Identifiable {
    let id: UUID = UUID()
    var text: String = ""
    var letter: String 
    var isChecked: Bool = false
}



