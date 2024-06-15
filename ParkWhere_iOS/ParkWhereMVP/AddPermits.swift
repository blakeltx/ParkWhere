//
//  AddPermits.swift
//  ParkWhereMVP
//
//  Created by Blake Lauritsen on 3/5/23.
//

import SwiftUI

struct AddPermits: View {
    @State private var searchText = ""
    @EnvironmentObject var modelData: ModelData
    @EnvironmentObject var filterManager: FilterManager
    
    var filteredPermits: [Permit] {
        if searchText.isEmpty {
            return modelData.dataPermits
        } else {
            return modelData.dataPermits.filter { $0.title.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    var body: some View {
        VStack{
            SearchBar(text: $searchText)
            List {
                ForEach(filteredPermits) { permit in
                    PermitRow(permit: permit)
                }
            }
        }
        .navigationTitle("Manage Permits")
    }
}

struct AddPermits_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let filterManager = FilterManager(modelData: ModelData())
    static var previews: some View {
        AddPermits()
            .environmentObject(ModelData())
            .environmentObject(filterManager)
    }
}
