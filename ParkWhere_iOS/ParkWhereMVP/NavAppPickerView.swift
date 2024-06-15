import SwiftUI
import Combine
enum Selection: String, CaseIterable {
    case appleMaps = "Apple Maps"
    case googleMaps = "Google Maps"
    case waze = "Waze"
}

struct PersistentPicker: View {
    @ObservedObject var settingsStore: SettingsStore = SettingsStore()
    @State var clubIndex = 1
    @State var selectedSelection: [Selection] = Selection.allCases
    
    var body: some View {
        Picker("", selection: self.$settingsStore.selectedSelection) {
            ForEach(self.selectedSelection, id: \.self) { Fav in
                Text(Fav.rawValue).tag(Fav)
            }
        }
        .pickerStyle(.segmented)
    }
}

final class SettingsStore: ObservableObject {
    let theSelection = PassthroughSubject<Void, Never>()
    var selectedSelection: Selection = UserDefaults.navApp {
        willSet {
            UserDefaults.navApp = newValue
            print(UserDefaults.navApp)
            theSelection.send()
        }
    }
}

extension UserDefaults {
    private struct Keys {
        static let navApp = "navApp"
    }
    static var navApp: Selection {
        get {
            if let value = UserDefaults.standard.object(forKey: Keys.navApp) as? String {
                return Selection(rawValue: value)!
            }
            else {
                return .appleMaps
            }
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Keys.navApp)
        }
    }
}

struct PersistentPicker_Previews: PreviewProvider {
    static var previews: some View {
        PersistentPicker()
    }
}
