//
//  MenuView.swift
//  ParkWhereMVP
//
//

import SwiftUI
import MessageUI
import AVFoundation
import Foundation
import UIKit

struct MenuView: View {
    @EnvironmentObject var modelData: ModelData
    @EnvironmentObject var filterManager: FilterManager
    
    @State var isShowingMailView = false
    @State var alertNoMail = false
    @State var result: Result<MFMailComposeResult, Error>? = nil
    var body: some View {
        VStack {
            Spacer()
            NavigationLink(destination: ManagePermitsView()
                .environmentObject(modelData)
                .environmentObject(filterManager)) {
                    VStack {
                        Image(systemName: "car.fill")
                            .resizable()
                            .foregroundColor(.accentColor)
                            .frame(width: 75, height: 70)
                        Text("Manage Permits")
                            .foregroundColor(.black)
                            .font(.headline)
                    }
                }
                .padding()
            Button(action: {
                MFMailComposeViewController.canSendMail() ? self.isShowingMailView.toggle() : self.alertNoMail.toggle()
            }) {
                VStack {
                    Image(systemName: "envelope.fill")
                        .resizable()
                        .foregroundColor(.accentColor)
                        .frame(width: 75, height: 70)
                    Text("Contact Us")
                        .foregroundColor(.black)
                        .font(.headline)
                }
            }
            .sheet(isPresented: $isShowingMailView) {
                MailView(result: self.$result)
            }
            .alert(isPresented: self.$alertNoMail) {
                Alert(title: Text("NO MAIL SETUP"))
            }
            
            NavigationLink(destination: HelpfulLinks()){
                VStack {
                    Image(systemName: "link")
                        .resizable()
                        .accentColor(Color(red: 0.31, green: 0, blue: 0))
                        .frame(width: 75, height: 70)
                    Text("Helpful Links")
                        .foregroundColor(.black)
                        .font(.headline)
                }
            }
            Spacer()
            
            Text("Open Navigation in")
                .padding(.top, 10)
            PersistentPicker()
                .padding(.horizontal)
            Text("https://transport.tamu.edu/")
            Text("\(Image(systemName: "c.circle")) The 418s")
        }
        .padding()
        .navigationTitle("Menu")
    }
}

struct MenuView_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let filterManager = FilterManager(modelData: ModelData())
    static var previews: some View {
        MenuView()
            .environmentObject(modelData)
            .environmentObject(filterManager)
    }
}

//***************************************************//

struct MailView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentation
    @Binding var result: Result<MFMailComposeResult, Error>?
    var recipients = ["contact@the418s.dev"]
    var messageBody = "Enter Message Here"
    var subject = "What is the subject of this discussion?"
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        @Binding var presentation: PresentationMode
        @Binding var result: Result<MFMailComposeResult, Error>?
        
        init(presentation: Binding<PresentationMode>,
             result: Binding<Result<MFMailComposeResult, Error>?>)
        {
            _presentation = presentation
            _result = result
        }
        
        func mailComposeController(_: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?)
        {
            defer {
                $presentation.wrappedValue.dismiss()
            }
            guard error == nil else {
                self.result = .failure(error!)
                return
            }
            self.result = .success(result)
            
            if result == .sent {
                AudioServicesPlayAlertSound(SystemSoundID(1001))
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(
            presentation: presentation, result: $result)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.setToRecipients(recipients)
        vc.setSubject(subject)
        vc.setMessageBody(messageBody, isHTML: true)
        vc.mailComposeDelegate = context.coordinator
        return vc
    }
    
    func updateUIViewController(_: MFMailComposeViewController,
                                context _: UIViewControllerRepresentableContext<MailView>) {}
}
