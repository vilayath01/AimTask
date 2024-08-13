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



