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
    @Published var regionFromViewModel: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @Published var geofenceRegionsOnly: [CLCircularRegion] = []
    @Published var searchResults: [MKLocalSearchCompletion] = []
    @Published var errorMessage: String?
    @Published var addressName: String = ""
    @Published var position: MapCameraPosition = .automatic
    
    // Geofence-related properties
    @Published var tasks: [TaskModel] = []
    @Published var geofenceRegions: [String: CLCircularRegion] = [:] {
        didSet {
            geofenceRegionsOnly = Array(geofenceRegions.values)
        }
    }
    
    private var geocoder = CLGeocoder()
    private var completer = MKLocalSearchCompleter()
    private var cancellables = Set<AnyCancellable>()
    private var locationManager = CLLocationManager()
    private var fdbManager: FDBManager
    
    private var previousLocation: CLLocation?
    
    init(fdbManager: FDBManager = FDBManager()) {
        self.fdbManager = fdbManager
        super.init()
        setupBindings()
        fetchTasks()
        
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
    
    func setupBindings() {
        
        fdbManager.$tasks
            .receive(on: DispatchQueue.main)
            .sink { [weak self] tasks in
                print("Tasks updated: \(tasks.count)")
                self?.tasks = tasks
                self?.updateGeofences()
            }
            .store(in: &cancellables)
        
        $searchText
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .receive(on: DispatchQueue.main) // Ensure updates happen on the main thread
            .sink { [weak self] text in
                self?.completer.queryFragment = text
            }
            .store(in: &cancellables)
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
                    self?.regionFromViewModel = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
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
    
    func updateSearchText(_ text: String) {
        DispatchQueue.main.async {
            self.searchText = text
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
                    self?.regionFromViewModel = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
                    self?.position = .region(self?.regionFromViewModel ?? MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)))
                    
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
        if let previousLocation = previousLocation {
            let distance = location.distance(from: previousLocation)
            if distance < 2.0 {  // Only update if the location has changed by more than 10 meters
                return
            }
        }
        //         Update the previousLocation to the current one
        previousLocation = location
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
                print("This is loc: \(location)")
                guard let placemark = placemarks?.first else { return }
                self?.addressName = "\(placemark.name ?? ""), \(placemark.locality ?? ""), \(placemark.country ?? "")."
                self?.regionFromViewModel = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
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
        guard task.coordinate.latitude != 0.0 && task.coordinate.longitude != 0.0 else {
            print("Invalid coordinates for task \(task.documentID)")
            return
        }
        
        let geofenceRegion = CLCircularRegion(
            center: task.coordinate,
            radius: 100.0,
            identifier: task.documentID
        )
        
        geofenceRegion.notifyOnEntry = true
        geofenceRegion.notifyOnExit = true
        
        startMonitoring(geofenceRegion: geofenceRegion)
        
        print("This is geo: \(geofenceRegion)")
        
        geofenceRegions[task.documentID] = geofenceRegion
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
        if let circularRegion = region as? CLCircularRegion,
           let task = tasks.first(where: { $0.documentID == circularRegion.identifier }) {
            fdbManager.updateEnteredGeofence(for:task.documentID , to: true)
            
            let title = task.locationName
            let body = "Tasks: " + task.taskItems.joined(separator: ", ")
            LocalNotifications.shared.scheduleNotification(title: title, body: body)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if let circularRegion = region as? CLCircularRegion,
           let task = tasks.first(where: { $0.documentID == circularRegion.identifier }) {
            
            fdbManager.updateEnteredGeofence(for:task.documentID , to: false)
            
            let title = task.locationName
            let body = "You have exited the area of task: \(task.locationName)."
            LocalNotifications.shared.scheduleNotification(title: title, body: body)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Failed to monitor region: \(error.localizedDescription)")
    }
}
