//
//  LotListRow.swift
//  ParkWhereMVP
//
//  Created by William Hatcher on 12/9/22.
//

import SwiftUI
import CoreLocation



struct LotListRow: View {
    var lot: Lot
    @State private var occupancy: Float = -1.0
    @ObservedObject var lm = LocationManager()
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    switch lot.type {
                    case .lot:
                        Image(systemName: "parkingsign.circle")
                    case .garage:
                        Image(systemName: "building.2.crop.circle")
                    }
                    Text(lot.title)
                }
                HStack {
                    // Occupancy
                    // TODO: Fix this logic!
                    if occupancy < 0 {
                        Text("Available")
                    } else if occupancy == 0 {
                        Text("Empty ").foregroundColor(.green)
                    } else if occupancy <= 0.25 {
                        Text("Almost empty ").foregroundColor(.green).font(.subheadline)
                    } else if occupancy < 0.75 {
                        Text("About half full ").foregroundColor(.yellow).font(.subheadline)
                    } else if occupancy < 1  {
                        Text("Almost full \(occupancy) ").foregroundColor(.orange).font(.subheadline)
                    } else {
                        Text("Full ").foregroundColor(.red).font(.subheadline)
                    }
                    
                    // Distance
//                    Text("Lot Loc \(lot.location.latitude), \(lot.location.longitude)")
//                    Text("Dev Loc \(lm.location?.latitude ?? -1), \(lm.location?.longitude ?? -1)")
                    Text(String(
                        format: "- %.2f mi",
                        (lm.location?.distance(from: CLLocationCoordinate2D(latitude: lot.location.latitude, longitude: lot.location.longitude)) ?? 0) * 0.0006213712
                    ))
                        .font(.subheadline)
                }.task {
                    occupancy =  await lot.occupancy
                }
            }
            
            Spacer()
            Button {} label: {
                Image(systemName: "info.circle")
            }
                .tint(.accentColor)
                .buttonBorderShape(.roundedRectangle)
                .controlSize(.regular)
            Button("Go") {
//                let appleMapURL = URL(string: "maps://?daddr=\(lot.location.latitude),\(lot.location.longitude)")!
                let googleMapURL = URL(string:"https://www.google.com/maps/dir/?api=1&dir_action=navigate&destination=\(lot.location.latitude),\(lot.location.longitude)")!
                if UIApplication.shared.canOpenURL(googleMapURL) {
                      UIApplication.shared.open(googleMapURL, options: [:], completionHandler: nil)
                }
            }
                .tint(.green)
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle)
                .controlSize(.large)
        }.padding()
    }
}

struct LotListRow_Previews: PreviewProvider {
    static var previews: some View {
        LotListRow(lot: dataLots[0])
            .previewLayout(.sizeThatFits)
    }
}
