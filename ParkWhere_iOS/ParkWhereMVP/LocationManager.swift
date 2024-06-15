//
//  LocationManager.swift
//  ParkWhereMVP
//
//
import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject {
    private var locationManager = CLLocationManager()
    let objectWillChange = PassthroughSubject<Void, Never>()
    
    @Published var status: CLAuthorizationStatus? {
        willSet { objectWillChange.send() }
    }
    
    @Published var location: CLLocation? {
        willSet { objectWillChange.send() }
    }
    
    private var initialLocationSet = false
    
    override init() {
        super.init()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    func requestSingleLocationUpdate() {
        locationManager.startUpdatingLocation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [locationManager] in
            locationManager.stopUpdatingLocation()
        }
    }
    
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.status = status
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            manager.stopUpdatingLocation()
        }
    }
}

extension CLLocation {
    var latitude: Double {
        return self.coordinate.latitude
    }
    
    var longitude: Double {
        return self.coordinate.longitude
    }
    
    /// Return distance in meters
    func distance(from coords: CLLocationCoordinate2D) -> CLLocationDistance {
        return self.distance(from: CLLocation(latitude: coords.latitude, longitude: coords.longitude))
    }
}
