//
//  SearchBarView.swift
//  ParkWhereMVP
//
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    @State private var keyboardHeight: CGFloat = 0
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField("search", text: $text)
                .onTapGesture {
                    // Set the focus to the search bar when it is tapped
                    UIApplication.shared.sendAction(#selector(UIResponder.becomeFirstResponder), to: nil, from: nil, for: nil)
                }
                .disabled(false) // Remove this line
        }
        .padding(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 6))
        .foregroundColor(.secondary)
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(10.0)
    }
}

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        SearchBar(text: .constant(""))
    }
}
