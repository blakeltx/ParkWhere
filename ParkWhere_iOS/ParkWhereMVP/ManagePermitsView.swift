//
//  ManagePermitsView.swift
//  ParkWhereMVP
//
//

import SwiftUI

struct ManagePermitsView: View {
    @EnvironmentObject var modelData: ModelData
    @EnvironmentObject var filterManager: FilterManager
    
    var body: some View {
        VStack {
            ZStack {
                Text("My Permits")
                    .fontWeight(.bold)
                    .font(.title)
                    .frame(width: 335, height: 0)
                    .foregroundColor(.black)
            }
            NavigationLink(destination: AddPermits()
                .environmentObject(modelData)
                .environmentObject(filterManager)) {
                    HStack {
                        Image(systemName: "rectangle.and.pencil.and.ellipsis")
                        Text("Edit Permits")
                    }
                }
                .padding()
            VStack {
                HStack {
                    Image(systemName: "bolt.car")
                        .accentColor(Color(red: 0.31, green: 0, blue: 0))
                    Spacer().frame(width: 10)
                    Text("Active Permits")
                        .fontWeight(.bold)
                        .font(.title)
                    Spacer()
                }
                .padding(EdgeInsets(top: 40, leading: 40, bottom: 8, trailing: 8))
                ActivePermitsView()
            }
            
            
            VStack {
                HStack {
                    Image(systemName: "exclamationmark.circle")
                        .accentColor(Color(red: 0.31, green: 0, blue: 0))
                    Spacer().frame(width: 10)
                    Text("Expired Permits")
                        .fontWeight(.bold)
                        .font(.title)
                    Spacer()
                }
                .padding(EdgeInsets(top: 0, leading: 40, bottom: 8, trailing: 8))
                ExpiredPermitsView()
            }
            
            //RoundedRectangle(cornerRadius: 8).frame(height: 200)
            //.padding(EdgeInsets(top: 0, leading: 40, bottom: 75, trailing: 40))
            
            VStack {
                Text("https://transport.tamu.edu/")
                    .padding()
                HStack {
                    Image(systemName: "c.circle")
                    Text("The 418s")
                }
            }
        }
        
    }
}

struct ActivePermitsView : View{
    @EnvironmentObject var modelData: ModelData
    
    func filterActivePermits() -> [Permit] {
        var activeFilteredPermits = [Permit]()
        
        let currentDate = Date()
        
        for permit in modelData.dataPermits {
            if permit.isChecked {
                if let expirationDate = permit.expirationDate, currentDate.compare(expirationDate) == .orderedAscending {
                    activeFilteredPermits.append(permit)
                }
            }
        }
        
        return activeFilteredPermits
    }
    
    
    var activePermits: [Permit] {
        filterActivePermits()
    }
    
    var body: some View {
        ScrollView{
            VStack(alignment: .leading, spacing: 16) {
                ForEach(activePermits, id: \.self) { permit in
                    HStack {
                        Text(permit.title)
                            .font(.headline)
                        Spacer()
                    }
                    
                }
            }
            .padding(EdgeInsets(top: 0, leading: 40, bottom: 0, trailing: 0))
            .padding(.top)
        }
    }
}

struct ExpiredPermitsView : View{
    @EnvironmentObject var modelData : ModelData
    func filterExpiratedPermits() -> [Permit] {
        var exFilteredPermits = [Permit]()
        
        let currentDate = Date()
        
        for permit in modelData.dataPermits {
            if permit.isChecked {
                if let expirationDate = permit.expirationDate, currentDate.compare(expirationDate) == .orderedDescending {
                    exFilteredPermits.append(permit)
                }
            }
        }
        
        return exFilteredPermits
    }
    var exPermits: [Permit] {
        filterExpiratedPermits()
    }
    
    var body: some View {
        ScrollView{
            VStack(alignment: .leading, spacing: 16) {
                ForEach(exPermits, id: \.self) { permit in
                    HStack {
                        Text(permit.title)
                            .font(.headline)
                        Spacer()
                    }
                    
                }
            }
            .padding(EdgeInsets(top: 0, leading: 40, bottom: 0, trailing: 0))
            .padding(.top)
        }
    }
}

struct ManagePermitsView_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let filterManager = FilterManager(modelData: ModelData())
    static var previews: some View {
        ManagePermitsView()
            .environmentObject(modelData)
            .environmentObject(filterManager)
    }
}
