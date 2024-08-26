//
//  GeocodingViewModel.swift
//  AimTask
//
//  Created by Vilayath Mohammed on 4/8/2024.
//

import Foundation
import MapKit
import Combine
import SwiftUI

class AddTaskMapViewModel: NSObject, ObservableObject {
    
    @Published var searchText: String = ""
    @Published var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @Published var searchResults: [MKLocalSearchCompletion] = []
    @Published var errorMessage: String?
    @Published var addressName: String = ""
    @Published var tasks: [TaskModel] = []
    private var geofenceRegions: [String: CLCircularRegion] = [:]
    private var geocoder = CLGeocoder()
    private var completer = MKLocalSearchCompleter()
    private var cancellables = Set<AnyCancellable>()
    private var locationManager = CLLocationManager()
    private var fdbManager: FDBManager
    
    init(fdbManager: FDBManager = FDBManager()) {
        self.fdbManager = fdbManager
        super.init()
        
        fetchTasks()
        setupBindings()
        
        completer.resultTypes = .address
        completer.delegate = self
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        
    }
    
    private func setupBindings() {
        $searchText
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] text in
                self?.completer.queryFragment = text
            }
            .store(in: &cancellables)
    }
    
    func updateSearchText(_ text: String) {
        DispatchQueue.main.async {
            self.searchText = text
        }
    }
    
    func performGeocoding(for address: String) {
        guard !address.isEmpty else { return }
        
        geocoder.geocodeAddressString(address) { [weak self] (placemarks, error) in
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription
                }
                return
            }
            
            if let placemark = placemarks?.first,
               let location = placemark.location {
                DispatchQueue.main.async {
                    self?.region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
                    self?.errorMessage = nil
                }
            } else {
                DispatchQueue.main.async {
                    self?.errorMessage = "No location found."
                }
            }
        }
    }
    
    func selectCompletion(_ completion: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        search.start { [weak self] (response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription
                }
                return
            }
            
            if let coordinate = response?.mapItems.first?.placemark.coordinate {
                self?.updateSearchText("\(response?.mapItems.first?.placemark.title ?? ""), \(response?.mapItems.first?.placemark.subtitle ?? "")")
                DispatchQueue.main.async {
                    self?.region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
                    self?.addressName = "\(response?.mapItems.first?.placemark.name ?? ""), \(response?.mapItems.first?.placemark.locality ?? ""), \(response?.mapItems.first?.placemark.country ?? "")."
                    self?.errorMessage = nil
                }
            } else {
                DispatchQueue.main.sync {
                    self?.errorMessage = error?.localizedDescription ?? "No location found"
                }
            }
        }
    }
    
    // Map Recenter
    func centerOnUserLocation() {
        if let location = locationManager.location {
            centerMap(on: location.coordinate, animated: true)
        }
    }
    
    func centerMap(on coordinate: CLLocationCoordinate2D, animated: Bool) {
        if animated {
            withAnimation(.easeInOut(duration: 1.0)) {
                region.center = coordinate
                region.span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            }
        } else {
            region.center = coordinate
        }
    }
}

extension AddTaskMapViewModel: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            self.searchResults = completer.results
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.errorMessage = error.localizedDescription
        }
    }
}

extension AddTaskMapViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization authorizationStatus: CLAuthorizationStatus) {
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            locationManager.requestLocation()
        } else if authorizationStatus == .denied || authorizationStatus == .restricted {
            DispatchQueue.main.async {
                self.errorMessage = "Location access is restricted or denied."
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
                DispatchQueue.main.async {
                    guard let placemark = placemarks?.first else {
                        return
                    }
                    
                    self?.addressName = "\(placemark.name ?? ""), \(placemark.locality ?? ""), \(placemark.country ?? "")."
                }
                
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.errorMessage = error.localizedDescription
        }
    }
}

extension CLLocationCoordinate2D: Identifiable {
    public var id: String {
        "\(latitude), \(longitude)"
    }
}


// Geofence
extension AddTaskMapViewModel {
    
    func fetchTasks() {
        fdbManager.fetchTasks()
        fdbManager.$tasks
            .sink { [weak self] tasks in
                self?.tasks = tasks
                self?.updateGeofences()
            }
            .store(in: &cancellables)
    }
    
    
    private func updateGeofences() {
        clearGeofences()
        
        // Add new geofences for each task
        for task in tasks {
            addGeofence(for: task)
        }
        
        print("Updated geofences: \(geofenceRegions.keys)")
    }
    
    func clearGeofences() {
        for region in geofenceRegions.values {
//            locationManager.stopMonitoring(for: region)
            stopMonitoring(geofenceRegion: region)
            print("Stopped monitoring for geofence: \(region.identifier)")
        }
        geofenceRegions.removeAll()
        print("Cleared all geofences")
    }
    
    func addGeofence(for task: TaskModel) {
        let geofenceRegion = CLCircularRegion(
            center: task.coordinate,
            radius: 100.0, // Define the radius for the geofence
            identifier: task.documentID
        )
        
        geofenceRegion.notifyOnEntry = true
        geofenceRegion.notifyOnExit = true
        
        // Start monitoring the geofence region
//        locationManager.startMonitoring(for: geofenceRegion)
        startMonitoring(geofenceRegion: geofenceRegion)
        
        // Store the region for future reference
        geofenceRegions[task.documentID] = geofenceRegion
        print("Started monitoring geofence for task: \(task.documentID) / \(task.locationName)")
    }

    func startMonitoring(geofenceRegion: CLCircularRegion) {
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            locationManager.startMonitoring(for: geofenceRegion)
            print("This is monitor region: \(geofenceRegion.identifier)")
        } else {
            print("Geofenceing is not supported on this device.")
        }
    }
    
    func stopMonitoring(geofenceRegion: CLCircularRegion) {
        locationManager.stopMonitoring(for: geofenceRegion)
    }
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("this is region\(region.identifier)")
        if region is CLCircularRegion {
            print("Entered geofence: \(region.identifier)")
            // Handle entry event
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            print("Exited geofence: \(region.identifier)")
            // Handle exit event
        }
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Failed to monitor region: \(error.localizedDescription)")
    }
}


