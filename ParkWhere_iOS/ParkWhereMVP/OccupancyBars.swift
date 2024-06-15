//
//  OccupancyBars.swift
//  ParkWhereMVP
//
//

import SwiftUI

private struct Border: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 5)
            .stroke(Color.accentColor, lineWidth: 1)
    }
}

private struct BarSegment: View {
    var filled: Bool = true
    var fillColor: Color
    /*
    {
        return filled ? .accentColor : .clear
    }
     */
    var body: some View {
        RoundedRectangle(cornerRadius: 5, style: .continuous )
            .fill(filled ? fillColor.opacity(0.35) : .white)
            .overlay(Border())
    }
}


struct OccupancyBars: View {
    @StateObject private var lot_occ = OccupancyGetter()
    var lot: Lot
    @State private var barColor: Color = .green
    var body: some View {
        HStack {
            BarSegment(filled: lot_occ.occupancy > 0.0 ? true : false,
                       fillColor: barColor
            )
            BarSegment(filled: lot_occ.occupancy > 1.0 ? true : false,
                       fillColor: barColor)
            BarSegment(filled: lot_occ.occupancy > 2.0 ? true : false,
                       fillColor: barColor)
        }.task {
            await lot_occ.fetchOccupancy(lot: lot)
            if (lot_occ.occupancy > 2.0) {
                barColor = .red
            } else if ( lot_occ.occupancy > 1.0) {
                barColor = .orange
            } else if (lot_occ.occupancy >  0.0) {
                barColor = .green
            }
        }
    }
}

struct OccupancyBars_Previews: PreviewProvider {
    static let modelData = ModelData()
    static var previews: some View {
        OccupancyBars(
            lot: modelData.dataLots[0])
        .frame(width: 300,
               height: 30)
        .previewLayout(.sizeThatFits)
    }
}
