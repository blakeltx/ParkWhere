//
//  FilterManager.swift
//  ParkWhereMVP
//
//  Created by Blake Lauritsen on 4/5/23.
//

import Foundation
import Combine
import CoreLocation


class FilterManager: ObservableObject {
    @Published var modelData: ModelData
    @Published var filterOptions: [Filter] = []
    @Published var filteredLots: [Lot] = []
    @Published var filteredPermits: [Permit] = []
    @Published var specialEventOptions: [SpecialEvent] = []
    
    private var subscriptions = Set<AnyCancellable>()
    
    private var filterFunctions: [String: ([Lot]) -> [Lot]] {
        [
            "radial_AllLots": radial_AllLots_Filter,
            "radial_PermitCompatibleLotsOnly": radial_PermitCompatibleLotsOnly_Filter,
            "lotType_BothSurfaceLotsAndGarages": lotType_BothSurfaceLotsAndGarages_Filter,
            "lotType_SurfaceLots": lotType_SurfaceLots_Filter,
            "lotType_Garages": lotType_Garages_Filter,
            "lotSpecific_Visitor(Paid)Parking": lotSpecific_VisitorPaidParking_Filter,
            "lotSpecific_ElectricVehicle": lotSpecific_ElectricVehicle_Filter,
        ]
    }
    
    init(modelData: ModelData) {
        self.modelData = modelData
        self.filteredLots = modelData.dataLots
        self.filterOptions = modelData.dataFilters
        self.specialEventOptions = modelData.dataSpecialEvents
        updateActiveFilters()
        updateActivePermits()
        
        // Subscribe to filter options changes
        $filterOptions
            .sink { [weak self] _ in
                self?.updateActiveFilters()
            }
            .store(in: &subscriptions)
        
        $specialEventOptions
            .sink { [weak self] _ in
                self?.updateActiveFilters()
            }
            .store(in: &subscriptions)
    }
    
    internal func updateActiveFilters() {
        print("Initial lots count: \(filteredLots.count)")
        
        // Apply basic and special filters first
        var filteredLotsByType: [Lot] = modelData.dataLots
        
        // Apply lotSpecific
        for filter in filterOptions where filter.isChecked && filter.type == .lotSpecific {
            let filterKey = "\(filter.type.rawValue)_\(filter.title.replacingOccurrences(of: " ", with: ""))"
            if let filterFunction = filterFunctions[filterKey] {
                filteredLotsByType = filterFunction(filteredLotsByType)
                print("After applying filter \(filter.title), lots count: \(filteredLotsByType.count)")
            }
        }
        
        // Apply lotType filters
        if let activeLotTypeFilter = filterOptions.first(where: { $0.isChecked && $0.type == .lotType }) {
            let filterKey = "\(activeLotTypeFilter.type.rawValue)_\(activeLotTypeFilter.title.replacingOccurrences(of: " ", with: ""))"
            if let filterFunction = filterFunctions[filterKey] {
                filteredLotsByType = filterFunction(filteredLotsByType)
                print("After applying filter \(activeLotTypeFilter.title), lots count: \(filteredLotsByType.count)")
            }
        }
        
        // Apply radial filters
        if let activeRadialFilter = filterOptions.first(where: { $0.isChecked && $0.type == .radial }) {
            let filterKey = "\(activeRadialFilter.type.rawValue)_\(activeRadialFilter.title.replacingOccurrences(of: " ", with: ""))"
            if let filterFunction = filterFunctions[filterKey] {
                filteredLotsByType = filterFunction(filteredLotsByType)
                print("After applying filter \(activeRadialFilter.title), lots count: \(filteredLotsByType.count)")
            }
        }
        
        // Get the active special event filter
        if let activeSpecialEvent = specialEventOptions.first(where: { $0.isChecked && $0.type != "None"}) {
            // Apply special event filter
            filteredLotsByType = hasNecessaryPermitForSpecialEvent(lots: filteredLotsByType, specialEvent: activeSpecialEvent)
            print("After applying special events, lots count: \(filteredLotsByType.count)")
        }
        
        filteredLots = filteredLotsByType
        print("filtered lots : \(filteredLots.count)")
    }
    
    internal func updateActivePermits() {
        print("Initial permits count: \(filteredPermits.count)")
        
        var myPermits = [Permit]()
        
        let currentDate = Date()
        
        for permit in modelData.dataPermits {
            if permit.isChecked {
                if let expirationDate = permit.expirationDate, currentDate.compare(expirationDate) == .orderedAscending {
                    myPermits.append(permit)
                }
            }
        }
        
        filteredPermits = myPermits
        print("Filtered permits count: \(filteredPermits.count)")
    }
    
    func radialFiltersToAllLots() {
        for index in filterOptions.indices {
            if filterOptions[index].type == .radial {
                filterOptions[index].isChecked = (filterOptions[index].id == "0000")
            }
        }
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ///Radial
    
    func radial_AllLots_Filter(lots: [Lot]) -> [Lot] {
        // Implement the logic for the All Lots filter
        return lots
    }
    
    func radial_PermitCompatibleLotsOnly_Filter(lots: [Lot]) -> [Lot] {
        // Implement the logic for the Permit Compatible Lots Only filter
        var allFilteredLots = [Lot]()
        
        for permit in filteredPermits {
            for lot in lots {
                if permit.includedLots.contains(lot.title) {
                    allFilteredLots.append(lot)
                }
            }
        }
        return allFilteredLots
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ///LotType
    func lotType_BothSurfaceLotsAndGarages_Filter(lots: [Lot]) -> [Lot] {
        // Implement the logic for the Surface Lots filter
        return lots
    }
    
    func lotType_SurfaceLots_Filter(lots: [Lot]) -> [Lot] {
        // Implement the logic for the Surface Lots filter
        return lots.filter { $0.type == .lot }
    }
    
    func lotType_Garages_Filter(lots: [Lot]) -> [Lot] {
        // Implement the logic for the Garages filter
        return lots.filter { $0.type == .garage }
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ///LotSpecific
    
    func lotSpecific_ElectricVehicle_Filter(lots: [Lot]) -> [Lot] {
        // Implement the logic for the Electric Vehicle filter
        return lots.filter { $0.ev_slots > 0 }
    }
    
    func lotSpecific_VisitorPaidParking_Filter(lots: [Lot]) -> [Lot] {
        // Implement the logic for the Visitor (Paid) Parkingfilter
        return lots.filter { $0.visitor_slots > 0 }
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ///Special Events
    func hasNecessaryPermitForSpecialEvent(lots: [Lot], specialEvent: SpecialEvent) -> [Lot] {
        var hasPermit : Bool = false
        var filteredEventLots : [String] = []
        var newEventLots : [String] = []
        for (overrideLot, overridePermits) in specialEvent.lot_overrides {
            for lot in lots {
                if lot.title == overrideLot {
                    print("  Override Lot Title Found: \(overrideLot)")
                    hasPermit = false
                    for overridePermit in overridePermits {
                        for permit in filteredPermits {
                            if permit.title == overridePermit{
                                print("    Correct Override Permit Found: \(overridePermit)")
                                hasPermit = true
                                break
                            }
                        }
                        if hasPermit == true{
                            break
                        }
                    }
                    if hasPermit == false {
                        filteredEventLots.append(overrideLot)
                    }
                    hasPermit = false
                }
                else{
                    hasPermit = false
                    for overridePermit in overridePermits {
                        for permit in filteredPermits {
                            if permit.title == overridePermit{
                                print("    Correct Override Permit Found: \(overridePermit)")
                                hasPermit = true
                                break
                            }
                        }
                        if hasPermit == true{
                            newEventLots.append(overrideLot)
                            break
                        }
                    }
                    hasPermit = false
                    
                }
            }
        }
        print("Applying Lot Deletions: \(filteredEventLots)")
        // Filter out the lots that should not be accessible
        var updatedLots = lots.filter { !filteredEventLots.contains($0.title) }

        // Iterate through newEventLots and find the corresponding lots in dataLots
        for newEventLotTitle in newEventLots {
            // Check if the lot is already in updatedLots
            if !updatedLots.contains(where: { $0.title == newEventLotTitle }) {
                // If not, find the lot in dataLots and add it to updatedLots
                if let newLot = modelData.dataLots.first(where: { $0.title == newEventLotTitle }) {
                    updatedLots.append(newLot)
                }
            }
        }

        // Return the updated list of lots
        return updatedLots

    }
    
    // Add more filter functions here if needed
}
