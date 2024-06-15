//
//  ContactUsView.swift
//  ParkWhereMVP
//
//  Created by Tristan Paschall on 2/13/23.
//

import SwiftUI
import Foundation
import MessageUI
import AVFoundation
import UIKit

struct ContactUsView: View {
    @State var user_name = ""
    @State var user_email = ""
    @State var user_message = ""
    
    @State var isShowingMailView = false
    @State var alertNoMail = false
    @State var result: Result<MFMailComposeResult, Error>? = nil
    var body: some View {
        VStack(spacing: 29.85){
            HStack {
                RoundedRectangle(cornerRadius: 8)
                .fill(Color(red: 0.50, green: 0.23, blue: 0.27, opacity: 0.50))
                .frame(width: 35.34, height: 35.34)
                .offset(x: 20)
                
                Text("Contact Us")
                    .fontWeight(.bold)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .frame(width: 335, height: 44)
                    .offset(x: -30, y: 0)
            }
            
            HStack(spacing: 12.94) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(red: 0.50, green: 0.23, blue: 0.27, opacity: 0.50))
                    .frame(width: 10.99, height: 11.44)
            
                TextField("Full Name*", text: $user_name)
                    .font(.footnote)
                    .frame(width: 285.15, height: 27, alignment: .leading)
                    .foregroundColor(.black)
            }
            .padding(.leading, 23)
            .padding(.trailing, 4)
            .padding(.top, 12)
            .padding(.bottom, 11)
            .frame(width: 336, height: 50)
            .background(Color.white)
            .cornerRadius(9)
            .frame(width: 336, height: 50)
            
            HStack(spacing: 12.46) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(red: 0.50, green: 0.23, blue: 0.27, opacity: 0.50))
                    .frame(width: 10.99, height: 11.44)
            
                TextField("Email*", text: $user_email)
                    .font(.caption)
                    .frame(width: 275.18, height: 24.68, alignment: .leading)
                }
                .padding(.leading, 23)
                .padding(.trailing, 13)
                .padding(.top, 13)
                .padding(.bottom, 12)
                .frame(width: 336, height: 50)
                .background(Color.white)
                .cornerRadius(9)
                .frame(width: 336, height: 50)
            
            VStack(alignment: .trailing, spacing: 246.44) {
                TextField("Message*", text: $user_message, axis: .vertical)
                    .font(.caption)
                    .frame(width: 267.82, height: 83.33, alignment: .leading)
                    .lineLimit(10)
                    .multilineTextAlignment(.leading)
                
                VStack(alignment: .trailing, spacing: 4.44) {
                            Rectangle().rotationEffect(.degrees(-122.77))
                                .frame(maxWidth: .infinity, maxHeight: 1)
                
                            Rectangle().rotationEffect(.degrees(-122.77))
                                .frame(maxWidth: .infinity, maxHeight: 1)
                        }
                        .padding(.leading, 3277)
                        .padding(.bottom, 432)
                        .frame(width: 10.61, height: 16.48)
                }
                .padding(.leading, 22)
                .padding(.trailing, 1)
                .padding(.top, 4)
                .padding(.bottom, 1)
                .frame(width: 336, height: 306)
                .background(Color.white)
                .cornerRadius(9)
                .frame(width: 336, height: 306)
            
            Button("Send Message") {
                MFMailComposeViewController.canSendMail() ? self.isShowingMailView.toggle() : self.alertNoMail.toggle()
                            }
                                //            .disabled(!MFMailComposeViewController.canSendMail())
                                .sheet(isPresented: $isShowingMailView) {
                                    MailView(result: self.$result)
                            }
                            .alert(isPresented: self.$alertNoMail) {
                                Alert(title: Text("NO MAIL SETUP"))
            }
                .fontWeight(.medium)
                .font(.caption)
                .multilineTextAlignment(.center)
                .frame(width: 121, height: 27)
                .background(Color(red: 0, green: 0.48, blue: 1))
                .cornerRadius(9)
                .offset(x: 110)
        }
        .padding(.leading, 24)
        .padding(.trailing, 27)
        .padding(.top, 8)
        .padding(.bottom, 189)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .background(Color.gray)
    }
}

struct ContactUsView_Previews: PreviewProvider {
    static var previews: some View {
        ContactUsView()
    }
}

struct MailView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentation
    @Binding var result: Result<MFMailComposeResult, Error>?
    var recipients = [String]()
    var messageBody = ""
    
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
        return Coordinator(presentation: presentation,
                           result: $result)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.setToRecipients(recipients)
        vc.setMessageBody(messageBody, isHTML: true)
        vc.mailComposeDelegate = context.coordinator
        return vc
    }
    
    func updateUIViewController(_: MFMailComposeViewController,
                                context _: UIViewControllerRepresentableContext<MailView>) {}
    }
