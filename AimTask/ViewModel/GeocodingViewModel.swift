//
//  GeocodingViewModel.swift
//  AimTask
//
//  Created by Vilayath Mohammed on 4/8/2024.
//

import Foundation
import MapKit
import Combine


class GeocodingViewModel: NSObject, ObservableObject {
    @Published var searchText: String = ""
    @Published var region: MKCoordinateRegion
    @Published var searchResults: [MKLocalSearchCompletion] = []
    @Published var erroMessage: String?
    
    private var geocoder = CLGeocoder()
    private var completer = MKLocalSearchCompleter()
    private var cancellables = Set<AnyCancellable>()
    private var locationManager = CLLocationManager()
    
    init(region: MKCoordinateRegion) {
        self.region = region
        super.init()
        setupBindins()
        completer.resultTypes = .address
        completer.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    private func setupBindins() {
        $searchText.debounce(for: .seconds(0.5), scheduler: DispatchQueue.main).removeDuplicates().sink { [weak self] text in
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
        guard !address.isEmpty else {return}
        
        geocoder.geocodeAddressString(address) { [weak self] (placemarks, error) in
            if let error = error {
                self?.erroMessage = error.localizedDescription
                return
            }
            
            if let placemark = placemarks?.first,
               let location = placemark.location {
                self?.region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta:  0.05))
                self?.erroMessage = nil
                    
            } else {
                self?.erroMessage = "No location found."
            }
        }
    }
    
    func selectCompletion(_ completion: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        search.start { [weak self] (response, error) in
            if let error = error {
                self?.erroMessage = error.localizedDescription
                return
            }
            
            if let coordinate = response?.mapItems.first?.placemark.coordinate {
                self?.region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
                self?.erroMessage = nil
            } else {
                self?.erroMessage = error?.localizedDescription ?? "No location found"
            }
        }
    }
    
    func currentUserLocation() {
        guard CLLocationManager.locationServicesEnabled() else {
            self.erroMessage = "Location services are not enable"
            return
        }
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            self.erroMessage = "Location access is restricted or denied."
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        @unknown default:
            self.erroMessage = "Unkown autorization status."
        }
    }
}

extension GeocodingViewModel: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.searchResults = completer.results
    }
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: any Error) {
        self.erroMessage = error.localizedDescription
    }
}

extension GeocodingViewModel: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization authorizationStatus: CLAuthorizationStatus) {
           if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
               locationManager.requestLocation()
           } else if authorizationStatus == .denied || authorizationStatus == .restricted {
               self.erroMessage = "Location access is restricted or denied."
           }
       }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        self.erroMessage = error.localizedDescription
    }
}

extension CLLocationCoordinate2D: Identifiable {
    public var id: String {
        "\(latitude), \(longitude)"
    }
}
