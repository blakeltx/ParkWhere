//
//  ContentView.swift
//  ParkWhereMVP
//
//

import SwiftUI
import MapKit
import ArcGIS

struct ContentView: View {
    @State private var position = CardPosition.middle
    @State private var searchText = "" //
    @State private var pOISearchText: String = ""
    @State private var searchResults: [AGSGeocodeResult] = []
    @State private var showSearchView = false
    @State private var showSearchBar = false
    @State private var mapView = AGSMapView()
    @State private var myLots : [Lot] = []
    let poisearch = POISearch()
    @State private var selectedPOICoordinates: CLLocationCoordinate2D?
    @ObservedObject var lm = LocationManager()
    @EnvironmentObject var modelData: ModelData
    @EnvironmentObject var filterManager: FilterManager
    
    var filterLots : [Lot] {
        if searchText.isEmpty {
            return filterManager.filteredLots
        } else {
            return filterManager.filteredLots.filter { $0.title.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    var distanceSortedLots: [Lot] {
        myLots = filterLots.sorted {
            let location1 = CLLocation(latitude: $0.location.latitude, longitude: $0.location.longitude)
            let location2 = CLLocation(latitude: $1.location.latitude, longitude: $1.location.longitude)
            
            let referenceLocation = selectedPOICoordinates.map({ CLLocation(latitude: $0.latitude, longitude: $0.longitude) }) ?? lm.location
            
            let distance1 = (referenceLocation?.distance(from: location1) ?? 0) * 0.0006213712
            let distance2 = (referenceLocation?.distance(from: location2) ?? 0) * 0.0006213712
            
            return distance1 < distance2
        }
        
        return myLots
    }
    
    init(){
        lm.requestSingleLocationUpdate()
        selectedPOICoordinates = lm.location?.coordinate
    }
    
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                ArcGISMap(map: AGSMap(basemapStyle: .arcGISCommunity),
                          operationalLayers: [
                            AGSArcGISTiledLayer(url: URL(string: "https://gis.tamu.edu/arcgis/rest/services/FCOR/TAMU_BaseMap/MapServer")!),
                            AGSFeatureLayer(featureTable: AGSServiceFeatureTable(url: URL(string: "https://gis.tamu.edu/arcgis/rest/services/TS/TS_Main/MapServer/6")!))
                          ],
                          mapView: $mapView,
                          selectedPOICoordinates: $selectedPOICoordinates,
                          myLots: $myLots
                ).ignoresSafeArea()
                
                TextField("Search for a point of interest", text: $pOISearchText)
                    .padding()
                    .background(Color(.systemGray2))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .padding(.top, showSearchView ? 0 : 10)
                    .onTapGesture {
                        showSearchView = true
                    }.onChange(of: pOISearchText) { newValue in
                        // Query Suggestion API
                        print("on change")
                        poisearch.search(query: newValue)
                    }
                    .onSubmit {
                        // Send to geocode
                        print("pOISearchText changed: \(pOISearchText)")
                        poisearch.search(query: pOISearchText)
                    }
                
                SlideOverCard($position, backgroundStyle: .constant(.blur)) {
                    VStack {
                        HStack {
                            Image(systemName: "location.magnifyingglass")
                                .resizable()
                                .foregroundColor(.accentColor)
                                .frame(width: 25, height: 25)
                                .onTapGesture {
                                    showSearchBar.toggle()
                                    position = CardPosition.top
                                    searchText = ""
                                }.padding()
                            NavigationLink(
                                destination: FilterView()
                                    .environmentObject(modelData)
                                    .environmentObject(filterManager)
                                ,
                                label: {
                                    Image(systemName: "slider.horizontal.3")
                                        .resizable()
                                        .foregroundColor(.accentColor)
                                        .frame(width: 25, height: 25)
                                }
                            ).padding()
                            NavigationLink(
                                destination: MenuView()
                                    .environmentObject(modelData)
                                    .environmentObject(filterManager),
                                label: {
                                    Image(systemName: "line.3.horizontal")
                                        .resizable()
                                        .foregroundColor(.accentColor)
                                        .frame(width: 20, height: 20)
                                }
                            ).padding()
                            Button(action: {
                                lm.requestSingleLocationUpdate()
                                if let userLocation = lm.location {
                                    selectedPOICoordinates = nil
                                    selectedPOICoordinates = userLocation.coordinate
                                }
                            }) {
                                Image(systemName: "location.fill")
                                    .resizable()
                                    .foregroundColor(.accentColor)
                                    .frame(width: 20, height: 20)
                            }.padding()
                        }
                        if showSearchBar{
                            SearchBar(text: $searchText)
                                .onChange(of: filterManager.filteredLots) { _ in
                                    DispatchQueue.main.async {
                                        searchText = ""
                                    }
                                }
                        }
                        List(distanceSortedLots, id: \.self) { lot in
                            if let selectedCoordinates = selectedPOICoordinates {
                                LotRow(lot: lot, selectedPOILocation: selectedCoordinates)
                            } else if let userCoordinates = lm.location?.coordinate {
                                LotRow(lot: lot, selectedPOILocation: userCoordinates)
                            } else {
                                LotRow(lot: lot, selectedPOILocation: CLLocationCoordinate2D())
                            }
                        }
                        .id(UUID())
                        .listStyle(.automatic)
                        .scrollContentBackground(.hidden)
                        .overlay(VStack {
                            if filterManager.filteredPermits.isEmpty && myLots.isEmpty {
                                Text("Welcome to ParkWhere. Please add your permits or show all lots.")
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                NavigationLink(
                                    destination: AddPermits()
                                        .environmentObject(ModelData())
                                )
                                {
                                    Text("+ Add Permits")
                                }.buttonStyle(.borderedProminent)
                                
                                Button("Show All Lots") {
                                    filterManager.radialFiltersToAllLots()
                                }
                                Spacer()
                            }
                            else if myLots.isEmpty {
                                VStack {
                                    Text("No Lots match your filters")
                                    NavigationLink(destination: FilterView()) {
                                        Text("Change Filters")
                                    }
                                    Spacer()
                                }
                            }
                        }
                        )
                        
                    }.padding(EdgeInsets(top: 2, leading: 8, bottom: 8, trailing: 0))
                        .onAppear(){
                            filterManager.updateActivePermits()
                            filterManager.updateActiveFilters()
                        }
                }
                
                if showSearchView {
                    ZStack {
                        Color.white.ignoresSafeArea()
                        VStack {
                            HStack {
                                TextField("Search for a point of interest", text: $pOISearchText)
                                    .padding().background(Color(.systemGray5)).cornerRadius(8).padding(.horizontal)
                                Button(action: {
                                    showSearchView = false
                                    pOISearchText = ""
                                }) {Text("Cancel")}
                            }
                            
                            List(poisearch.results, id: \.placemark) { result in
                                Button(action: {
                                    print("Selected POI: \(result.name ?? "")")
                                    if let location = result.placemark.location {
                                        print("Coordinates: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                                        selectedPOICoordinates = location.coordinate
                                    }
                                    pOISearchText = result.name ?? ""
                                    showSearchView = false
                                }) {
                                    VStack(alignment: .leading) {
                                        Text(result.name ?? "")
                                            .font(.headline)
                                        Text("(\(result.placemark.location?.coordinate.latitude ?? 0), \(result.placemark.location?.coordinate.longitude ?? 0))")
                                            .font(.subheadline)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
        }
        .preferredColorScheme(.light)
        .accentColor(Color.accentColor)
        .navigationTitle("Live Map")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ModelData())
            .environmentObject(FilterManager(modelData: ModelData()))
    }
}
