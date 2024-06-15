//
//  POISearch.swift
//  ParkWhereMVP
//
//  Created by Blake Lauritsen on 4/3/23.
//

import Foundation
import MapKit
import SwiftUI

class POISearch: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var results: [MKMapItem] = []
    @Published var suggestions: [String] = []
    private var suggestionCompletion: (([String]) -> Void)?
    private var searchRegion: MKCoordinateRegion!
    
    enum POISearchError: Error {
        case noResults
    }
    
    override init() {
        super.init()
        setSearchRegion()
    }
    
    func setSearchRegion() {
        let center = CLLocationCoordinate2D(latitude: 30.6185, longitude: -96.3390) // Texas A&M University coordinates
        let span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2) // Adjust the span as needed
        searchRegion = MKCoordinateRegion(center: center, span: span)
    }
    
    func suggestionSearch(query: String, completion: @escaping ([String]) -> Void) {
        let completer = MKLocalSearchCompleter()
        completer.delegate = self
        completer.queryFragment = query
        completer.region = searchRegion
        completer.resultTypes = .query // Update this if you need more result types
        
        suggestionCompletion = completion
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        let suggestions = completer.results.map { $0.title }
        suggestionCompletion?(suggestions)
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Error: \(error.localizedDescription)")
    }
    
    func searchFirst(coordinates: CLLocationCoordinate2D, completion: @escaping (Result<MKMapItem, Error>) -> Void) {
        let request = MKLocalSearch.Request()
        request.region = searchRegion
        let allCategories: [MKPointOfInterestCategory] = [.airport, .amusementPark, .aquarium, .bank, .beach, .brewery, .cafe, .campground, .carRental, .evCharger, .fireStation, .fitnessCenter, .foodMarket, .gasStation, .hospital, .hotel, .laundry, .library, .marina, .movieTheater, .museum, .nationalPark, .nightlife, .park, .parking, .pharmacy, .police, .postOffice, .publicTransport, .restaurant, .restroom, .school, .stadium, .store, .theater, .university, .zoo]
        request.pointOfInterestFilter = MKPointOfInterestFilter(including: allCategories)
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(.failure(error))
            } else if let response = response {
                let sortedResults = response.mapItems.sorted { (mapItem1, mapItem2) -> Bool in
                    let location1 = CLLocation(latitude: mapItem1.placemark.coordinate.latitude, longitude: mapItem1.placemark.coordinate.longitude)
                    let location2 = CLLocation(latitude: mapItem2.placemark.coordinate.latitude, longitude: mapItem2.placemark.coordinate.longitude)
                    let referenceLocation = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
                    let distance1 = referenceLocation.distance(from: location1)
                    let distance2 = referenceLocation.distance(from: location2)
                    return distance1 < distance2
                }
                if let firstResult = sortedResults.first {
                    completion(.success(firstResult))
                } else {
                    completion(.failure(POISearchError.noResults))
                }
            }
        }
    }
    
    func reverseGeocode(coordinates: CLLocationCoordinate2D, completion: @escaping (Result<MKMapItem, Error>) -> Void) {
        let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(.failure(error))
            } else if let placemark = placemarks?.first {
                let mapItem = MKMapItem(placemark: MKPlacemark(placemark: placemark))
                completion(.success(mapItem))
            } else {
                completion(.failure(POISearchError.noResults))
            }
        }
    }
    
    func search(query: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = searchRegion
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else if let response = response {
                self.results = response.mapItems
            }
        }
    }
    
    func isResultWithinRegion(_ result: MKMapItem) -> Bool {
        let coordinate = result.placemark.coordinate
        let minLatitude = searchRegion.center.latitude - (searchRegion.span.latitudeDelta / 2)
        let maxLatitude = searchRegion.center.latitude + (searchRegion.span.latitudeDelta / 2)
        let minLongitude = searchRegion.center.longitude - (searchRegion.span.longitudeDelta / 2)
        let maxLongitude = searchRegion.center.longitude + (searchRegion.span.longitudeDelta / 2)
        
        return minLatitude <= coordinate.latitude
        && coordinate.latitude <= maxLatitude
        && minLongitude <= coordinate.longitude
        && coordinate.longitude <= maxLongitude
    }
    
    func printResults() {
        for result in results {
            if isResultWithinRegion(result) {
                print("Name: \(result.name ?? "N/A")")
                print("PhoneNumber: \(result.phoneNumber ?? "N/A")")
                print("URL: \(result.url?.absoluteString ?? "N/A")")
                print("IsOpenForBusiness: \(result.isCurrentLocation)")
                print("Placemark:")
                print("  Name: \(result.placemark.name ?? "N/A")")
                print("  Title: \(result.placemark.title ?? "N/A")")
                print("  PostalCode: \(result.placemark.postalCode ?? "N/A")")
                print("  Country: \(result.placemark.country ?? "N/A")")
                if let location = result.placemark.location {
                    print("  Latitude: \(location.coordinate.latitude)")
                    print("  Longitude: \(location.coordinate.longitude)")
                } else {
                    print("  Latitude: N/A")
                    print("  Longitude: N/A")
                }
                print("\n")
            }
        }
    }
}
