
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
    
    @Published var jiraURLprefix: String {
        didSet { UserDefaults.standard.set(jiraURLprefix, forKey: "jiraURLprefix") }
    }
    
    @Published var jiraProjectprefixes: String {
        didSet { UserDefaults.standard.set(jiraProjectprefixes, forKey: "jiraProjectprefixes") }
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
    
    @Published var displayNamePlanned: String {
        didSet { UserDefaults.standard.set(displayNamePlanned, forKey: "displayNamePlanned") }
    }
    
    @Published var displayNameToday: String {
        didSet { UserDefaults.standard.set(displayNameToday, forKey: "displayNameToday") }
    }
    
    @Published var displayNameTomorrow: String {
        didSet { UserDefaults.standard.set(displayNameTomorrow, forKey: "displayNameTomorrow") }
    }
    
    @Published var displayNameQBI: String {
        didSet { UserDefaults.standard.set(displayNameQBI, forKey: "displayNameQBI") }
    }
    
    @Published var formatEmptySections: Bool {
        didSet { UserDefaults.standard.set(formatEmptySections, forKey: "formatEmptySections") }
    }
    
    @Published var footerItems: [String] {
        didSet { UserDefaults.standard.set(footerItems, forKey: "footerItems") }
    }
    
    init() {
        self.pullRequestURLprefix = loadPreference("pullRequestURLprefix", initially: "")
        self.jiraURLprefix = loadPreference("jiraURLprefix", initially: "")
        self.jiraProjectprefixes = loadPreference("jiraProjectprefixes", initially: "")
        self.standupEmail = loadPreference("standupEmail", initially: "")
        self.storageFileName = loadPreference("storageFileName", initially: "Standup")
        self.formatEmptySections = loadPreference("formatEmptySections", initially: false)
        
        self.resetBehaviorPlanned = loadPreferenceEnum("resetBehaviorPlanned", initially: ResetBehavior.discard)
        self.resetBehaviorToday = loadPreferenceEnum("resetBehaviorToday", initially: ResetBehavior.discard)
        self.resetBehaviorTomorrow = loadPreferenceEnum("resetBehaviorTomorrow", initially: ResetBehavior.toPlanned)
        self.resetBehaviorQbi = loadPreferenceEnum("resetBehaviorQbi", initially: ResetBehavior.discard)
        
        self.displayNamePlanned = loadPreference("displayNamePlanned", initially: "Planned")
        self.displayNameToday = loadPreference("displayNameToday", initially: "Today")
        self.displayNameTomorrow = loadPreference("displayNameTomorrow", initially: "Tomorrow")
        self.displayNameQBI = loadPreference("displayNameQBI", initially: "QBI")
        
        self.footerItems = loadPreference("footerItems", initially: [])
    }
}
