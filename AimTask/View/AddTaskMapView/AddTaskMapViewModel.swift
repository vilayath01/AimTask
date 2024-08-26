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
    //Map related properties
    @Published var searchText: String = ""
    @Published var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @Published var searchResults: [MKLocalSearchCompletion] = []
    @Published var errorMessage: String?
    @Published var addressName: String = ""
    
    // Geofence-related properties
    @Published var tasks: [TaskModel] = []
    private var geofenceRegions: [String: CLCircularRegion] = [:]
    
    //other properties
    private var geocoder = CLGeocoder()
    private var completer = MKLocalSearchCompleter()
    private var cancellables = Set<AnyCancellable>()
    private var locationManager = CLLocationManager()
    private var fdbManager: FDBManager
    
    private var previousLocation: CLLocation?
    
    init(fdbManager: FDBManager = FDBManager()) {
        self.fdbManager = fdbManager
        super.init()
        fetchTasks()
        setupBindings()
        completer.resultTypes = .address
        completer.delegate = self
        setupLocationManager()
    }
    
    private func setupLocationManager() {
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
            .receive(on: DispatchQueue.main) // Ensure updates happen on the main thread
            .sink { [weak self] text in
                self?.completer.queryFragment = text
            }
            .store(in: &cancellables)
    }
    
    func zoomInOption() {
        DispatchQueue.main.async {
            self.region.span.latitudeDelta /= 2.0
            self.region.span.longitudeDelta /= 2.0
        }
    }
    
    func zoomOutOption() {
        // Zoom out action
        let maxSpan: CLLocationDegrees = 180.0
        
        var newLatDalta = region.span.latitudeDelta * 2
        var newlongDelta = region.span.longitudeDelta * 2
        
        if newLatDalta > maxSpan {
            newLatDalta = maxSpan
        }
        
        if newlongDelta > maxSpan {
            newlongDelta = maxSpan
        }
        DispatchQueue.main.async {
            self.region.span = MKCoordinateSpan(latitudeDelta: newLatDalta, longitudeDelta: newlongDelta)
        }
        
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
                    self?.addressName = "\(placemark.name ?? ""), \(placemark.locality ?? ""), \(placemark.country ?? "")."
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
            reverseGeocodeLocation(location)
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
        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .denied, .restricted:
            DispatchQueue.main.async {
                self.errorMessage = "Location access is restricted or denied."
            }
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        // Compare with the previous location
        if let previousLocation = previousLocation {
            let distance = location.distance(from: previousLocation)
            if distance < 10 {  // Only update if the location has changed by more than 10 meters
                return
            }
        }
        
        // Update the previousLocation to the current one
        previousLocation = location
        
        // Perform reverse geocoding
        reverseGeocodeLocation(location)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.errorMessage = error.localizedDescription
        }
    }
    
    private func reverseGeocodeLocation(_ location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            DispatchQueue.main.async {
                guard let placemark = placemarks?.first else { return }
                self?.addressName = "\(placemark.name ?? ""), \(placemark.locality ?? ""), \(placemark.country ?? "")."
            }
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
        startMonitoring(geofenceRegion: geofenceRegion)
        
        // Store the region for future reference
        geofenceRegions[task.documentID] = geofenceRegion
        print("Started monitoring geofence for task: \(task.documentID) / \(task.locationName)")
    }
    
    func startMonitoring(geofenceRegion: CLCircularRegion) {
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            locationManager.startMonitoring(for: geofenceRegion)
            print("This is monitor region: \(geofenceRegion.identifier)/ \(geofenceRegion.radius)")
        } else {
            print("Geofenceing is not supported on this device.")
        }
    }
    
    func stopMonitoring(geofenceRegion: CLCircularRegion) {
        locationManager.stopMonitoring(for: geofenceRegion)
    }
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            print("Entered geofence: \(region.identifier)")
            // Handle entry event
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            print("Exited geofence: \(String(describing: manager.location))")
            // Handle exit event
        }
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Failed to monitor region: \(error.localizedDescription)")
    }
}


