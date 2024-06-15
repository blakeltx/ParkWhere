//
//  OccupancyReporting.swift
//  ParkWhereMVP
//
//  Created by William Hatcher on 4/17/23.
//

import SwiftUI

struct OccupancyReporting: View {
    @State private var lot_occupancy: Double = 1.5
    var callback: ((_ lot_occupancy: Double) -> Void)
    
    var body: some View {
        VStack {
            Text("About how full is this lot?")
            Slider(value: $lot_occupancy, in: 0...3) {
                Text("Current Occupancy")
            } minimumValueLabel: {
                Text("Empty")
            } maximumValueLabel: {
                Text("Full")
            }
            
#if DEBUG
            Text("\(lot_occupancy)")
#endif
            
            Button("Report Occupancy") {
                self.callback(lot_occupancy)
            }.buttonStyle(.borderedProminent)
        }
    }
}

struct OccupancyReporting_Previews: PreviewProvider {
    static var previews: some View {
        OccupancyReporting(callback: {lot_occupancy in
            print("Gotcha \(lot_occupancy)")
        })
    }
}
