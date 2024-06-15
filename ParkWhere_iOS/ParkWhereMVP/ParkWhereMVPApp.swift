//
//  ParkWhereMVPApp.swift
//  ParkWhereMVP
//
//  Created by William Hatcher on 12/9/22.
//

import SwiftUI

@main
struct ParkWhereMVPApp: App {
    @StateObject var modelData = ModelData()
    @StateObject var filterManager = FilterManager(modelData:  ModelData())
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(ModelData())
                .environmentObject(FilterManager(modelData: ModelData()))
                .accentColor(Color.accentColor)
        }
    }
}
