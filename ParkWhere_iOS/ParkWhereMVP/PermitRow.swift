//
//  PermitRow.swift
//  ParkWhereMVP
//
//

import SwiftUI
import UserNotifications

struct PermitRow: View {
    var permit: Permit
    @EnvironmentObject var modelData: ModelData
    @EnvironmentObject var filterManager: FilterManager
    
    var permitIndex: Int {
        modelData.dataPermits.firstIndex(where: { $0.id == permit.id })!
    }
    
    var isCheckedBinding: Binding<Bool> {
        Binding<Bool>(
            get: { permit.isChecked },
            set: { newValue in
                modelData.dataPermits[permitIndex].isChecked = newValue
                UserDefaults.standard.set(newValue, forKey: permit.id)
                // Remove notification if unchecked
                if !newValue {
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [permit.id])
                }
            }
        )
    }
    
    var dateBinding: Binding<Date> {
        Binding<Date>(
            get: { permit.expirationDate ?? Date() },
            set: { newValue in
                modelData.dataPermits[permitIndex].expirationDate = newValue
                UserDefaults.standard.set(newValue, forKey: "\(permit.id)-expirationDate")
                
                // Remove notification if date set to past
                if newValue <= Date() {
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [permit.id])
                } else if permit.isChecked && newValue > Date() {
                    // Request Notifications
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                        if success {
                            print("All set!")
                        } else if let error = error {
                            print(error.localizedDescription)
                        }
                    }
                    // Set Notification
                    let content = UNMutableNotificationContent()
                    content.sound = UNNotificationSound.default
                    var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: newValue)
                    dateComponents.hour = 9
                    
                    // Test if selected date is less than 7 days away
                    if newValue.timeIntervalSinceNow >= 604800 {
                        // Notify them 7 days before expiring
                        dateComponents.day = dateComponents.day! - 7
                        content.title = "Your \"\(permit.title)\" permit has expired!"
                    } else {
                        content.title = "Your \"\(permit.title)\" permit is expiring in 7 days!"
                    }
                    
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                    
                    let request = UNNotificationRequest(identifier: permit.id, content: content, trigger: trigger)
                    
                    // add our notification request
                    UNUserNotificationCenter.current().add(request)
                    print("Requested NOTIF")
                }
            }
        )
    }
    
    var body: some View {
        HStack {
            Toggle(permit.title, isOn: isCheckedBinding)
                .toggleStyle(iOSCheckboxToggleStyle())
            Spacer()
            ChangeDate(selectedDate: dateBinding).padding()
                .disabled(!permit.isChecked)
        }
    }
}


struct ChangeDate: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedDate: Date  // Update the selectedDate to a Binding<Date> variable
    
    var body: some View {
        VStack {
            Text("Expires on").padding(EdgeInsets(top: 0, leading: 0, bottom: -10, trailing: 0))
            DatePicker("Expires on", selection: $selectedDate, displayedComponents: .date)
                .labelsHidden()
        }
    }
}

struct iOSCheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }, label: {
            HStack {
                Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                configuration.label.foregroundColor(.primary)
            }
        })
        .buttonStyle(.borderless)
    }
}

struct PermitRow_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let filterManager = FilterManager(modelData: ModelData()) // Add this line // NOT HELPFUL AT ALL
    static var previews: some View {
        PermitRow(permit: modelData.dataPermits[0])
            .environmentObject(ModelData())
            .environmentObject(filterManager)
    }
}
