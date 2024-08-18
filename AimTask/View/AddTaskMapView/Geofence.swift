//
//  Geofence.swift
//  AimTask
//
//  Created by Vilayath Mohammed on 18/8/2024.
//

import Foundation
import MapKit

struct Geofence {
    let coordinate: CLLocationCoordinate2D
    let radius: CLLocationDistance
    let identifier: String
}

