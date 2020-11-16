
import Foundation

private func loadPreference<T:Codable>(_ name: String, initially: T) -> T {
    if let pref = UserDefaults.standard.object(forKey: name) as? T {
        return pref
    }
    return initially
}

private func loadPreferenceEnum<T:RawRepresentable>(_ name: String, initially: T) -> T where T.RawValue == String {
    if let prefString = UserDefaults.standard.object(forKey: name) as? String {
        if let enumPref = T(rawValue: prefString) {
            return enumPref
        }
    }
    return initially
}

class UserSettings: ObservableObject {
    enum ResetBehavior: String { case discard, toPlanned, keep }
    
    @Published var pullRequestURLprefix: String {
        didSet { UserDefaults.standard.set(pullRequestURLprefix, forKey: "pullRequestURLprefix") }
    }
    
    @Published var standupEmail: String {
        didSet { UserDefaults.standard.set(standupEmail, forKey: "standupEmail") }
    }
    
    @Published var storageFileName: String {
        didSet { UserDefaults.standard.set(storageFileName, forKey: "storageFileName") }
    }
    
    @Published var resetBehaviorPlanned: ResetBehavior {
        didSet { UserDefaults.standard.set(resetBehaviorPlanned.rawValue, forKey: "resetBehaviorPlanned") }
    }
    
    @Published var resetBehaviorToday: ResetBehavior {
        didSet { UserDefaults.standard.set(resetBehaviorToday.rawValue, forKey: "resetBehaviorToday") }
    }
    
    @Published var resetBehaviorTomorrow: ResetBehavior {
        didSet { UserDefaults.standard.set(resetBehaviorTomorrow.rawValue, forKey: "resetBehaviorTomorrow") }
    }
    
    @Published var resetBehaviorQbi: ResetBehavior {
        didSet { UserDefaults.standard.set(resetBehaviorQbi.rawValue, forKey: "resetBehaviorQbi") }
    }
    
    init() {
        self.pullRequestURLprefix = loadPreference("pullRequestURLprefix", initially: "")
        self.standupEmail = loadPreference("standupEmail", initially: "")
        self.storageFileName = loadPreference("storageFileName", initially: "Standup")
        
        self.resetBehaviorPlanned = loadPreferenceEnum("resetBehaviorPlanned", initially: ResetBehavior.discard)
        self.resetBehaviorToday = loadPreferenceEnum("resetBehaviorToday", initially: ResetBehavior.discard)
        self.resetBehaviorTomorrow = loadPreferenceEnum("resetBehaviorTomorrow", initially: ResetBehavior.toPlanned)
        self.resetBehaviorQbi = loadPreferenceEnum("resetBehaviorQbi", initially: ResetBehavior.discard)
    }
}
