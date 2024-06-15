//
//  RadialButton.swift
//  ParkWhereMVP
//
//

import SwiftUI

struct RadialButton: View {
    @Binding var isSelected: Bool
    @EnvironmentObject var modelData: ModelData
    var onTap: () -> Void
    
    var body: some View {
        Button(action: {
            onTap()
        }) {
            Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                .foregroundColor(isSelected ? .accentColor : .gray)
        }
    }
}


struct RadialButton_Previews: PreviewProvider {
    static var previews: some View {
        RadialButton(isSelected: .constant(false), onTap: {})
            .environmentObject(ModelData())
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
