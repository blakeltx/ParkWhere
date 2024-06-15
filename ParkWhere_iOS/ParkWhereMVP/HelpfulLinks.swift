//
//  HelpfulLinks.swift
//  ParkWhereMVP
//
//

import SwiftUI
private struct LinkData: Identifiable {
    let title: String
    let url: String
    let id = UUID()
}

private let links_array: [LinkData] = [
    LinkData(title: "Purchase Permits", url: "https://transport2.tamu.edu/Account/Login.aspx?ReturnUrl=%2faccount"),
    LinkData(title: "EV Parking Options", url: "https://transport.tamu.edu/Alternative/ev.aspx"),
    LinkData(title: "Visitor Parking", url: "https://transport.tamu.edu/Parking/visitor.aspx"),
    LinkData(title: "Special Event Parking", url: "https://transport.tamu.edu/Parking/events/sports.aspx"),
    LinkData(title: "Campus Event Parking", url: "https://transport.tamu.edu/Parking/events/annual.aspx"),
    LinkData(title: "Pay Parking Ticket", url: "https://transport.tamu.edu/account/paycitation/search.aspx"),
    LinkData(title: "Appeal Parking Ticket", url: "https://transport.tamu.edu/Parking/appeal.aspx"),
    LinkData(title: "RV Parking", url: "https://transport.tamu.edu/Parking/rvrules.aspx"),
    LinkData(title: "Football RV Lot Rules", url: "https://transport.tamu.edu/Parking/rvfootballseason.aspx"),
    LinkData(title: "Break & Summer, Night & Weekend Parking", url: "https://transport.tamu.edu/Parking/special.aspx#break"),
    LinkData(title: "HSC Parking", url: "https://transport.tamu.edu/Parking/index.html"),
    LinkData(title: "TAMU Parking Map", url: "https://transport.tamu.edu/parkingmap//tsmap.htm?map=main"),
    LinkData(title: "Aggie Map", url: "https://aggiemap.tamu.edu/")
]

struct HelpfulLinks: View {
    var body: some View {
        VStack{
            HStack {
                Image(systemName: "link")
                    .font(.title)
                Text("Helpful Links")
                    .fontWeight(.bold)
                    .font(.title)
                Spacer().frame(width:30)
            }
            .padding()
            
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(links_array) { link in
                        Link(link.title, destination: URL(string: link.url)!)
                    }
                }
            }
        }
    }
}

struct HelpfulLinks_Previews: PreviewProvider {
    static var previews: some View {
        HelpfulLinks()
    }
}
