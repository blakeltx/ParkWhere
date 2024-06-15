//
//  SwiftUIView.swift
//  ParkWhereMVP
//
//

import SwiftUI
import CoreLocation

func distanceFromSelectedPOI(_ selectedPOI: CLLocationCoordinate2D, lot: Lot) -> Double {
    let poiLocation = CLLocation(latitude: selectedPOI.latitude, longitude: selectedPOI.longitude)
    let lotLocation = CLLocation(latitude: lot.location.latitude, longitude: lot.location.longitude)
    return poiLocation.distance(from: lotLocation) * 0.0006213712
}

// New Lot Row
struct LotRow: View {
    var lot: Lot
    var selectedPOILocation: CLLocationCoordinate2D?
    @EnvironmentObject var modelData: ModelData
    @ObservedObject var lm = LocationManager()
    @State private var showInfo = false
    @State private var popoverPosition: CGPoint = .zero
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text(lot.title)
                            .fontWeight(.semibold)
                        Button {
                            self.showInfo.toggle()
                            self.popoverPosition = self.calculatePopoverPosition()
                        } label: {
                            Image(systemName: "info.circle")
                        }
                        .popover(isPresented: $showInfo, content: {
                            LotInfoPopover(lot: lot)
                        })
                    }
                    GeometryReader { metrics in
                        HStack {
                            OccupancyBars(lot: lot)
                                .frame(width: metrics.size.width/3)
                            Text(String(format: "- %.2f mi", distanceFromSelectedPOI(selectedPOILocation!, lot: lot)))
                        }
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    
                }
                Spacer()
                Button {
                    /// Open Nav App
                    openNav(for: lot)
                } label: {
                    Image(systemName: "arrow.right.circle")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .font(Font.title.weight(.thin))
                }
                .controlSize(.large)
                .buttonStyle(.borderless)
            }
        }
        .padding()
        .cornerRadius(15)
    }
    private func calculatePopoverPosition() -> CGPoint {
        let buttonPosition = CGPoint(x: 100, y: 100)
        let popoverSize = CGSize(width: 300, height: 300)
        let x = min(buttonPosition.x, UIScreen.main.bounds.width - popoverSize.width - 10)
        let y = min(buttonPosition.y, UIScreen.main.bounds.height - popoverSize.height - 10)
        return CGPoint(x: x, y: y)
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let userLocation = CLLocationCoordinate2D(latitude: 30.6177, longitude: -96.3367) // Example coordinates
    static var previews: some View {
        LotRow(lot: modelData.dataLots[0], selectedPOILocation: userLocation)
            .previewLayout(.sizeThatFits)
    }
}

func openNav(for lot: Lot) {
    let appleMapURL = URL(string: "maps://?daddr=\(lot.location.latitude),\(lot.location.longitude)")!
    let googleMapURL = URL(string:"https://www.google.com/maps/dir/?api=1&dir_action=navigate&destination=\(lot.location.latitude),\(lot.location.longitude)")!
    let wazeURL = URL(string:"https://waze.com/ul?ll=\(lot.location.latitude),\(lot.location.longitude)&navigate=yes")!
    var finalURL: URL
    switch (UserDefaults.navApp) {
    case .appleMaps:
        finalURL = appleMapURL
    case .googleMaps:
        finalURL = googleMapURL
    case .waze:
        finalURL = wazeURL
    }
    if UIApplication.shared.canOpenURL(finalURL) {
        UIApplication.shared.open(finalURL, options: [:], completionHandler: nil)
    }
}
