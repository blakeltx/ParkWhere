//
//  SpecialEventType.swift
//  ParkWhereMVP
//
//  Created by Blake Lauritsen on 4/19/23.
//

import Foundation

struct SpecialEvent: Hashable, Codable, Identifiable {
    var id: String
    var type: String // This is our own ID
    var lot_overrides:  [String: [String]]
    var isChecked: Bool {
        get {
            let storedValue = UserDefaults.standard.object(forKey: "\(id)-specialEventIsChecked")
            guard let storedValue else {
                return id == "000" // Default of "None"
            }
            return UserDefaults.standard.bool(forKey: "\(id)-specialEventIsChecked")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "\(id)-specialEventIsChecked")
        }
    }
}
//
