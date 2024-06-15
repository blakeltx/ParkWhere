//
//  FilterType.swift
//  ParkWhereMVP
//
//  Created by Blake Lauritsen on 4/10/23.
//

import Foundation

enum FilterType: String, Codable {
    case radial
    case lotType
    case lotSpecific
    case specialEvent
}

struct Filter: Hashable, Codable, Identifiable {
    var id: String // This is our own ID
    var type: FilterType
    let title: String
    var isChecked: Bool {
        get {
            let storedValue = UserDefaults.standard.object(forKey: "\(id)-filterIsChecked")
            if storedValue == nil {
                if type == .lotSpecific { // Handle radial button behavior
                    return id == "0010" // Defualt to "Both Surface Lots And Garages"
                } else if type == .radial { // Handle radial button behavior
                    return id == "0001" // Default to "Permit Compatible Lots Only"
                }
                else if type == .specialEvent { // Handle radial button behavior
                    return id == "1000" // Default to "None"
                }
            }
            return UserDefaults.standard.bool(forKey: "\(id)-filterIsChecked")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "\(id)-filterIsChecked")
        }
    }
}
