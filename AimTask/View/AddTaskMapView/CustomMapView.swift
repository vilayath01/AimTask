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
    @State var onPinSelection: MKMapItem?
    
    var body: some View {
        Map(position: $addTaskMapViewModel.position, selection: $onPinSelection) {
            
            if !addTaskMapViewModel.searchTextFromCustomMap.isEmpty {
                Marker(addTaskMapViewModel.addressName, image: "", coordinate: addTaskMapViewModel.regionFromViewModel.center)
            }
            
            // Geofence markers and circles
            ForEach(addTaskMapViewModel.geofenceRegionsOnly, id: \.identifier) { result in
                MapCircle(center: result.center, radius: 100.0)
                    .foregroundStyle(.orange.opacity(0.3))
                
                Marker("", image: "", coordinate: result.center)
            }
            
            if !addTaskMapViewModel.searchTextFromCustomMap.isEmpty {
                ForEach(addTaskMapViewModel.resultFromCustomMap, id: \.self) { item in
                    let placeMark = item.placemark
                    Marker(placeMark.name ?? "", coordinate: placeMark.coordinate)
                        .tint(Color.blue)
                }
                
            }
        }
        .onChange(of: onPinSelection, initial: false) {
            if let newValue = onPinSelection {
                DispatchQueue.main.async {
                    let name = newValue.name ?? ""
                    let title = newValue.placemark.title ?? ""
                    
                    addTaskMapViewModel.searchTextFromCustomMap = "\(name), \(title)"
                }
                
                Task {
                    await addTaskMapViewModel.searchForPlaces()
                }
            } else {
                DispatchQueue.main.async {
                    addTaskMapViewModel.searchTextFromCustomMap = ""
                }
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
