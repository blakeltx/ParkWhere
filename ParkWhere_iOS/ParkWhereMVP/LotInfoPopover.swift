//
//  LotInfoPopover.swift
//  ParkWhereMVP
//
//

import SwiftUI

struct LotInfoPopover: View {
    @State private var showingAlert = false
    @Environment(\.dismiss) var dismiss
    let lot: Lot
    @StateObject private var lot_occ = OccupancyGetter()
    var body: some View {
        VStack(alignment: .center) {
            Text(lot.title).bold()
            Text(lot.address ?? "No Address")
            
            if lot.type == .garage {
                Text("Availability: \(lot_occ.slots) / \(lot.total_slots)")
                    .task {
                        await lot_occ.fetchSlots(lot: lot)
                    }
            }
            
            Text("Total Parking Slots: \(lot.total_slots)")
            Text("Visitor (Paid) Slots: \(lot.visitor_slots)")
            Text("EV Slots: \(lot.ev_slots)")
            Text("Handicap Parking: \(lot.disabled_slots ?? 0)")
            if lot.type == .lot {
                OccupancyReporting { lot_occupancy in
                    print("Got Occ Report\(lot_occupancy)")
                    // Report Lot Occupancy
                    let ck_service = CloudKitService()
                    let oc_report = OccupancyReport(LotTitle: lot.title, Occupancy: lot_occupancy)
                    Task {
                        do {
                            try await ck_service.save(oc_report.record)
                        } catch {
                            print("Error saving CK Record")
                            print(error.localizedDescription)
                        }
                    }
                    self.showingAlert = true
                }.alert(isPresented: $showingAlert) {
                    Alert(title: Text("Thank you for your occupancy report"), dismissButton: .default(Text("You're welcome")) {
                        dismiss()
                    })
                }
            }
            Text("Swipe down to dismiss")
            HStack {
                Spacer()
                Image(systemName: "arrow.down")
                    .resizable()
                    .frame(width:20, height:20)
                Spacer()
            }
        }
    }
}

struct LotInfoPopover_Previews: PreviewProvider {
    static let modelData = ModelData()
    static var previews: some View {
        LotInfoPopover(lot: modelData.dataLots[0])
    }
}
