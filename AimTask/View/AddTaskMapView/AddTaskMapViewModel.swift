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
    @Published var searchTextFromCustomMap: String = ""
    @Published var regionFromViewModel: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        
    )
    @Published var addressName: String = ""
    @Published var position: MapCameraPosition = .automatic
    
    @Published var geofenceRegionsOnly: [CLCircularRegion] = []
    @Published var resultFromCustomMap: [MKMapItem] = []
    
    @Published var errorMessage: String = ""
    @Published var isPositve: Bool = false
    
    
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
    }
    
    func searchForPlaces() async {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchTextFromCustomMap
        request.region = regionFromViewModel
        
        do {
            let resultFromCustomMap = try await MKLocalSearch(request: request).start()
            
            DispatchQueue.main.async {
                self.resultFromCustomMap = resultFromCustomMap.mapItems
                guard let placemark = resultFromCustomMap.mapItems.first else { return }
                
                if let coordinate = resultFromCustomMap.mapItems.first?.placemark.coordinate {
                    let newRegion = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
                    self.position = .region(newRegion)
                    self.regionFromViewModel = newRegion
                    self.addressName = "\(placemark.name ?? "") \(placemark.placemark.title ?? "")."
                } else {
                    self.errorMessage = "No results found."
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Error searching for places: \(error.localizedDescription)"
            }
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
            if distance < 5.0 {
                return
            }
        }
        
        previousLocation = location
        reverseGeocodeLocation(location)
        
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            print("Issue2: \(error.localizedDescription)")
        }
    }
    
    private func reverseGeocodeLocation(_ location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            DispatchQueue.main.async {
                guard let placemark = placemarks?.first else { return }
                
                self?.addressName = "\(placemark.name ?? ""), \(placemark.locality ?? "")."
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
    }
    
    func clearGeofences() {
        for region in geofenceRegions.values {
            stopMonitoring(geofenceRegion: region)
        }
        geofenceRegions.removeAll()
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
        
        geofenceRegions[task.documentID] = geofenceRegion
    }
    
    func startMonitoring(geofenceRegion: CLCircularRegion) {
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            locationManager.startMonitoring(for: geofenceRegion)
        } else {
            self.errorMessage = "Geofenceing is not supported on this device."
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
        self.errorMessage = "Failed to monitor region: \(error.localizedDescription)"
    }
}
