//
//  SwiftUIView.swift
//  ParkWhereMVP
//
//  Created by William Hatcher on 2/6/23.
//

import SwiftUI

struct SwiftUIView: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Lot 100")
                    .fontWeight(.semibold)
                Text("Available - 0.2 mi")
                    .foregroundColor(.accentColor)
                    .font(.subheadline)
            }
            Spacer()
            Button {
                // TODO: Action
                print("Button Press")
            } label: {
//                ZStack {
//                    Image(systemName: "arrow.right").tint(.black)
//                    Circle()
//                        .stroke(Color.accentColor, lineWidth: 1.5)
//                        .frame(width: 45, height: 45)
//                }
                Image(systemName: "arrow.right.circle")
                    .resizable()
                    .frame(width: 50, height: 50)
            }
            .controlSize(.large)
        }.padding()
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIView().previewLayout(.sizeThatFits)
    }
}
