//
//  CustomMapView.swift
//  AimTask
//
//  Created by Vilayath Mohammed on 29/8/2024.
//

import Foundation
import SwiftUI
import MapKit

struct CustomMapView: View {
    @ObservedObject var addTaskMapViewModel: AddTaskMapViewModel
    
    var body: some View {
        Map(position: $addTaskMapViewModel.position) {
            
            if !addTaskMapViewModel.searchText.isEmpty {
                Marker(addTaskMapViewModel.addressName, image: "", coordinate: addTaskMapViewModel.regionFromViewModel.center)
            }

            // Geofence markers and circles
            ForEach(addTaskMapViewModel.geofenceRegionsOnly, id: \.identifier) { result in
                MapCircle(center: result.center, radius: 100.0)
                    .foregroundStyle(.orange.opacity(0.3))
                
                Marker("", image: "", coordinate: result.center)
            }
        }
        .mapStyle(.standard(elevation: .realistic))
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
        }
    }
}
