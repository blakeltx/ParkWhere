//
//  FilterView.swift
//  ParkWhereMVP
//
//  Created by Blake Lauritsen on 4/10/23.
//

import SwiftUI

struct FilterView: View {
    @EnvironmentObject var modelData: ModelData
    @EnvironmentObject var filterManager: FilterManager
    private var selectedRadialFilterId: String? {
        filterManager.filterOptions.first(where: { $0.isChecked && $0.type == .radial })?.id
    }
    
    private var selectedLotTypeFilterId: String? {
        filterManager.filterOptions.first(where: { $0.isChecked && $0.type == .lotType })?.id
    }
    //
    private var selectedSpecialEventFilterId: String? {
        filterManager.specialEventOptions.first(where: { $0.isChecked })?.id
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            // Radial Filters
            VStack(alignment:.leading) {
                Text("Permit Compatible Filter")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
                ForEach(filterManager.filterOptions.filter { $0.type == .radial }) { filter in
                    HStack {
                        RadialButton(isSelected: .constant(selectedRadialFilterId == filter.id), onTap: {
                            if selectedRadialFilterId != filter.id {
                                // Update the isChecked property of radial filters accordingly
                                for index in filterManager.filterOptions.indices {
                                    let currentFilter = filterManager.filterOptions[index]
                                    if currentFilter.type == .radial {
                                        filterManager.filterOptions[index].isChecked = currentFilter.id == filter.id
                                        print("Filter \(filter.title) isChecked: \(filter.isChecked)")
                                    }
                                }
                            }
                        })
                        Text(filter.title)
                    }
                }
            }
            Divider()
            // Lot Type Filters
            Text("Lot Type")
                .font(.title)
                .fontWeight(.bold)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
            VStack(alignment: .leading) {
                ForEach(filterManager.filterOptions.filter { $0.type == .lotType }) { filter in
                    HStack {
                        RadialButton(isSelected: .constant(selectedLotTypeFilterId == filter.id), onTap: {
                            if selectedLotTypeFilterId != filter.id {
                                // Update the isChecked property of radial filters accordingly
                                for index in filterManager.filterOptions.indices {
                                    let currentFilter = filterManager.filterOptions[index]
                                    if currentFilter.type == .lotType {
                                        filterManager.filterOptions[index].isChecked = currentFilter.id == filter.id
                                        print("Filter \(filter.title) isChecked: \(filter.isChecked)")
                                    }
                                }
                            }
                        })
                        Text(filter.title)
                        Spacer()
                    }
                }
            }
            Divider()
            // Lot Specific Filters
            Text("Lot Specific Features")
                .font(.title)
                .fontWeight(.bold)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
            VStack(alignment: .leading) {
                ForEach(filterManager.filterOptions.filter { $0.type == .lotSpecific }) { filter in
                    HStack {
                        Toggle(filter.title, isOn: Binding(get: {
                            return filterManager.filterOptions.first(where: { $0.id == filter.id })!.isChecked
                        }, set: { newValue in
                            if let index = filterManager.filterOptions.firstIndex(where: { $0.id == filter.id }) {
                                filterManager.filterOptions[index].isChecked = newValue
                                print("Filter \(filter.title) isChecked: \(filter.isChecked)")
                            }
                        })).toggleStyle(iOSCheckboxToggleStyle())
                    }
                }
            }
            Divider()
            // Special Events Filters
            Text("Special Events")
                .font(.title)
                .fontWeight(.bold)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
            VStack(alignment: .leading) {
                ForEach(filterManager.specialEventOptions) { specialEvent in
                    HStack {
                        RadialButton(isSelected: .constant(selectedSpecialEventFilterId == specialEvent.id), onTap: {
                            if selectedSpecialEventFilterId != specialEvent.id {
                                // Update the isChecked property of special events accordingly
                                for index in filterManager.specialEventOptions.indices {
                                    let currentSpecialEvent = filterManager.specialEventOptions[index]
                                    filterManager.specialEventOptions[index].isChecked = currentSpecialEvent.id == specialEvent.id
                                    print("SpecialEvent \(specialEvent.type) isChecked: \(specialEvent.isChecked)")
                                }
                            }
                        })
                        Text(specialEvent.type)
                    }
                }
            }
        }
        .navigationTitle("Filter Options")
        .padding()
    }
    
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        FilterView()
            .environmentObject(ModelData())
            .environmentObject(FilterManager(modelData: ModelData()))
    }
}
