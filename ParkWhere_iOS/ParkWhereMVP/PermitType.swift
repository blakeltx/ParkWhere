//
//  PermitType.swift
//  ParkWhereMVP
//
//

import Foundation


struct Permit : Hashable, Codable, Identifiable {
    var id: String // This is our own ID
    let title: String
    let includedLots : [String]
    var isChecked: Bool {
        get {
            UserDefaults.standard.bool(forKey: "\(id)-isChecked")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "\(id)-isChecked")
        }
    }
    
    var expirationDate: Date? {
        get {
            UserDefaults.standard.object(forKey: "\(id)-expirationDate") as? Date ?? Date()
        }
        set {
            
            UserDefaults.standard.set(newValue, forKey: "\(id)-expirationDate")
        }
    }
    
    
}
