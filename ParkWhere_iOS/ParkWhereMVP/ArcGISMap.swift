// Copyright 2021 Esri
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SwiftUI
import ArcGIS

struct ArcGISMap : UIViewRepresentable {
    let map: AGSMap
    let graphicsOverlays: [AGSGraphicsOverlay]
    var operationalLayers: [AGSLayer]
    @Binding var mapView: AGSMapView
    private var onSingleTapAction: ((CGPoint, AGSPoint) -> Void)?
    @Binding var selectedPOICoordinates: CLLocationCoordinate2D?
    @Binding var myLots: [Lot]
    // Add a new property for the graphics overlay
    private let selectedLocationGraphicsOverlay = AGSGraphicsOverlay()
    private let parkingLotGraphicsOverlay = AGSGraphicsOverlay()
    var buildingLayer: AGSFeatureLayer? {
        operationalLayers.count >= 2 ? operationalLayers[1] as? AGSFeatureLayer : nil
    }
    
    
    init(
        map: AGSMap,
        graphicsOverlays: [AGSGraphicsOverlay] = [],
        operationalLayers: [AGSLayer] = [],
        mapView: Binding<AGSMapView>,
        selectedPOICoordinates: Binding<CLLocationCoordinate2D?>,
        myLots: Binding<[Lot]>
    ) {
        self.map = map
        self.graphicsOverlays = graphicsOverlays
        self.operationalLayers = operationalLayers
        for layer in operationalLayers {
            self.map.operationalLayers.add(layer)
        }
        self._mapView = mapView
        self._selectedPOICoordinates = selectedPOICoordinates
        self._myLots = myLots
        AGSArcGISRuntimeEnvironment.apiKey = Bundle.main.object(forInfoDictionaryKey: "ARCGIS_API_KEY") as! String
    }
    
    func updateSelectedLocation(location: CLLocationCoordinate2D) {
        let point = AGSPoint(clLocationCoordinate2D: location)
        let viewpoint = AGSViewpoint(center: point, scale: 3_000)
        self.mapView.setViewpoint(viewpoint, completion: nil)
        
        // Remove existing graphics (if any)
        selectedLocationGraphicsOverlay.graphics.removeAllObjects()
        
        // Create a symbol for the graphic
        let symbol = AGSSimpleMarkerSymbol(style: .circle, color: .blue, size: 10)
        
        // Create a new graphic with the symbol and add it to the graphics overlay
        let graphic = AGSGraphic(geometry: point, symbol: symbol, attributes: nil)
        selectedLocationGraphicsOverlay.graphics.add(graphic)
    }
    
    func updateParkingLotGraphics(lots: [Lot]) {
        // Remove existing graphics (if any)
        parkingLotGraphicsOverlay.graphics.removeAllObjects()
        
        // Set a renderer for the parking lot graphics overlay
        let symbol = AGSSimpleMarkerSymbol(style: .square, color: .red, size: 10)
        //parkingLotGraphicsOverlay.renderer = AGSSimpleRenderer(symbol: symbol)
        
        for lot in lots {
            let point = AGSPoint(clLocationCoordinate2D: CLLocationCoordinate2D(latitude: lot.location.latitude, longitude: lot.location.longitude))
            let graphic = AGSGraphic(geometry: point, symbol: symbol, attributes: nil)
            parkingLotGraphicsOverlay.graphics.add(graphic)
        }
    }
}

extension ArcGISMap{
    typealias UIViewType = AGSMapView
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(
            onSingleTapAction: onSingleTapAction,
            selectedPOICoordinates: _selectedPOICoordinates
        )
    }
    
    func makeUIView(context: Context) -> AGSMapView {
        let uiView = AGSMapView()
        uiView.map = map
        uiView.graphicsOverlays.setArray(graphicsOverlays)
        uiView.touchDelegate = context.coordinator
        uiView.releaseHardwareResourcesWhenBackgrounded = true
        
        selectedLocationGraphicsOverlay.renderer = AGSSimpleRenderer(symbol: AGSSimpleMarkerSymbol(style: .circle, color: .blue, size: 10))
        uiView.graphicsOverlays.add(selectedLocationGraphicsOverlay)
        
        parkingLotGraphicsOverlay.renderer = AGSSimpleRenderer(symbol: AGSSimpleMarkerSymbol(style: .square, color: .red, size: 10))
        uiView.graphicsOverlays.add(parkingLotGraphicsOverlay)
        
        // no location ? initial viewpoint:
        let initialLatitude = 30.61248
        let initialLongitude = -96.34147
        let initialScale = 3_000.0
        map.initialViewpoint = AGSViewpoint(latitude: initialLatitude, longitude: initialLongitude, scale: initialScale)
        
        // Start update map when device location changes
        uiView.locationDisplay.start { error in
            if let error {
                print("Error in locationDisplay \(error.localizedDescription)")
                return
            }
            uiView.locationDisplay.autoPanMode = .recenter
        }
        
        // Call updateParkingLotGraphics method here after adding the parkingLotGraphicsOverlay
        if let location = selectedPOICoordinates{
            updateSelectedLocation(location: location)
        }
        updateParkingLotGraphics(lots: myLots)
        
        self.mapView = uiView // Update the binding
        return uiView
    }
    
    func updateUIView(_ uiView: AGSMapView, context: Context) {
        if map != uiView.map {
            uiView.map = map
        }
        if graphicsOverlays != uiView.graphicsOverlays as? [AGSGraphicsOverlay] {
            uiView.graphicsOverlays.setArray(graphicsOverlays)
        }
        if selectedLocationGraphicsOverlay != uiView.graphicsOverlays.lastObject as? AGSGraphicsOverlay {
            uiView.graphicsOverlays.add(selectedLocationGraphicsOverlay)
        }
        if parkingLotGraphicsOverlay != uiView.graphicsOverlays.lastObject as? AGSGraphicsOverlay {
            uiView.graphicsOverlays.add(parkingLotGraphicsOverlay)
        }
        self.mapView = uiView
        
        if let location = selectedPOICoordinates {
            updateSelectedLocation(location: location)
        }
        updateParkingLotGraphics(lots: myLots)
        
    }
}

extension ArcGISMap {
    class Coordinator: NSObject {
        var onSingleTapAction: ((CGPoint, AGSPoint) -> Void)?
        var selectedPOICoordinates: Binding<CLLocationCoordinate2D?>
        
        init(
            onSingleTapAction: ((CGPoint, AGSPoint) -> Void)?,
            selectedPOICoordinates: Binding<CLLocationCoordinate2D?>
        ) {
            self.onSingleTapAction = onSingleTapAction
            self.selectedPOICoordinates = selectedPOICoordinates
        }
    }
}

extension ArcGISMap.Coordinator: AGSGeoViewTouchDelegate {
    func geoView(_ geoView: AGSGeoView, didTapAtScreenPoint screenPoint: CGPoint, mapPoint mapLocation: AGSPoint) {
        // Project the AGSPoint to WGS84 (WKID 4326)
        let wgs84 = AGSSpatialReference(wkid: 4326)
        if let projectedPoint = AGSGeometryEngine.projectGeometry(mapLocation, to: wgs84!) as? AGSPoint {
            // Convert the projected AGSPoint to CLLocationCoordinate2D
            let location = CLLocationCoordinate2D(latitude: projectedPoint.y, longitude: projectedPoint.x)
            
            // Update the selectedPOICoordinates
            DispatchQueue.main.async {
                self.selectedPOICoordinates.wrappedValue = location
            }
        }
    }
}

struct ArcGISMap_Previews: PreviewProvider {
    @State private static var mapView = AGSMapView()
    @State private static var selectedPOICoordinates: CLLocationCoordinate2D?
    @State private static var myLots: [Lot] = []
    
    static var previews: some View {
        ArcGISMap(map: AGSMap(basemapStyle: .arcGISCommunity),
                  operationalLayers: [
                    AGSArcGISTiledLayer(url: URL(string: "https://gis.tamu.edu/arcgis/rest/services/FCOR/TAMU_BaseMap/MapServer")!),
                    AGSFeatureLayer(featureTable: AGSServiceFeatureTable(url: URL(string: "https://gis.tamu.edu/arcgis/rest/services/TS/TS_Main/MapServer/6")!))
                  ],
                  mapView: $mapView,
                  selectedPOICoordinates: $selectedPOICoordinates,
                  myLots: $myLots
        ).ignoresSafeArea()
    }
}

