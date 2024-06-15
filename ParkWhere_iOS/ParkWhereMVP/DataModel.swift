//
//  DataModel.swift
//  ParkWhereMVP
//
//  Created by Blake Lauritsen on 3/6/23.
//

import Foundation
import Combine
import SwiftUI

final class ModelData: ObservableObject {
    // Because you’ll never modify dataLots after initially loading it, you don’t need to mark it with the @Published attribute.
    let dataLots: [Lot] = load("parsed_lots.json")
    
    @Published var searchText = ""
    
    @Published var changed = false
    
    @Published var dataPermits: [Permit] = load("permits.json")
    
    @Published var dataFilters: [Filter] = load("filters.json")
    
    @Published var dataSpecialEvents : [SpecialEvent]  = load("special_events.json")
    
}

func load<T: Decodable>(_ filename: String) -> T {
    let data: Data
    
    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
    else {
        fatalError("Couldn't find \(filename) in main bundle.")
    }
    
    do {
        data = try Data(contentsOf: file)
    } catch{
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }
    
    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from:data)
    } catch{
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}

