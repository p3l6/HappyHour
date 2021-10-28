
import Foundation

fileprivate func loadPreference<T:Codable>(_ store: UserDefaults?, _ name: String, initially: T) -> T {
    if let store = store,
       let pref = store.object(forKey: name) as? T {
        return pref
    }
    return initially
}

fileprivate func loadPreferenceEnum<T:RawRepresentable>(_ store: UserDefaults?, _ name: String, initially: T) -> T where T.RawValue == String {
    if let store = store,
       let prefString = store.object(forKey: name) as? String {
        if let enumPref = T(rawValue: prefString) {
            return enumPref
        }
    }
    return initially
}

class UserSettings: ObservableObject {
    enum ResetBehavior: String { case discard, toPlanned, keep }
    let store: UserDefaults?
    
    @Published var pullRequestURLprefix: String {
        didSet { if let store = store { store.set(pullRequestURLprefix, forKey: "pullRequestURLprefix") } }
    }
    
    @Published var jiraURLprefix: String {
        didSet { if let store = store { store.set(jiraURLprefix, forKey: "jiraURLprefix") } }
    }
    
    @Published var jiraProjectprefixes: String {
        didSet { if let store = store { store.set(jiraProjectprefixes, forKey: "jiraProjectprefixes") } }
    }
    
    @Published var standupEmail: String {
        didSet { if let store = store { store.set(standupEmail, forKey: "standupEmail") } }
    }
    
    @Published var storageFileName: String {
        didSet { if let store = store { store.set(storageFileName, forKey: "storageFileName") } }
    }
    
    @Published var resetBehaviorPlanned: ResetBehavior {
        didSet { if let store = store { store.set(resetBehaviorPlanned.rawValue, forKey: "resetBehaviorPlanned") } }
    }
    
    @Published var resetBehaviorToday: ResetBehavior {
        didSet { if let store = store { store.set(resetBehaviorToday.rawValue, forKey: "resetBehaviorToday") } }
    }
    
    @Published var resetBehaviorTomorrow: ResetBehavior {
        didSet { if let store = store { store.set(resetBehaviorTomorrow.rawValue, forKey: "resetBehaviorTomorrow") } }
    }
    
    @Published var resetBehaviorQbi: ResetBehavior {
        didSet { if let store = store { store.set(resetBehaviorQbi.rawValue, forKey: "resetBehaviorQbi") } }
    }
    
    @Published var displayNamePlanned: String {
        didSet { if let store = store { store.set(displayNamePlanned, forKey: "displayNamePlanned") } }
    }
    
    @Published var displayNameToday: String {
        didSet { if let store = store { store.set(displayNameToday, forKey: "displayNameToday") } }
    }
    
    @Published var displayNameTomorrow: String {
        didSet { if let store = store { store.set(displayNameTomorrow, forKey: "displayNameTomorrow") } }
    }
    
    @Published var displayNameQBI: String {
        didSet { if let store = store { store.set(displayNameQBI, forKey: "displayNameQBI") } }
    }
    
    @Published var formatEmptySections: Bool {
        didSet { if let store = store { store.set(formatEmptySections, forKey: "formatEmptySections") } }
    }
    
    @Published var footerItems: [String] {
        didSet { if let store = store { store.set(footerItems, forKey: "footerItems") } }
    }
    
    convenience init() {
        self.init(store: UserDefaults.standard)
    }
    
    required init(store: UserDefaults?) {
        self.store = store
        
        self.pullRequestURLprefix = loadPreference(store, "pullRequestURLprefix", initially: "")
        self.jiraURLprefix = loadPreference(store, "jiraURLprefix", initially: "")
        self.jiraProjectprefixes = loadPreference(store, "jiraProjectprefixes", initially: "")
        self.standupEmail = loadPreference(store, "standupEmail", initially: "")
        self.storageFileName = loadPreference(store, "storageFileName", initially: "Standup")
        self.formatEmptySections = loadPreference(store, "formatEmptySections", initially: false)
        
        self.resetBehaviorPlanned = loadPreferenceEnum(store, "resetBehaviorPlanned", initially: ResetBehavior.discard)
        self.resetBehaviorToday = loadPreferenceEnum(store, "resetBehaviorToday", initially: ResetBehavior.discard)
        self.resetBehaviorTomorrow = loadPreferenceEnum(store, "resetBehaviorTomorrow", initially: ResetBehavior.toPlanned)
        self.resetBehaviorQbi = loadPreferenceEnum(store, "resetBehaviorQbi", initially: ResetBehavior.discard)
        
        self.displayNamePlanned = loadPreference(store, "displayNamePlanned", initially: "Planned")
        self.displayNameToday = loadPreference(store, "displayNameToday", initially: "Today")
        self.displayNameTomorrow = loadPreference(store, "displayNameTomorrow", initially: "Tomorrow")
        self.displayNameQBI = loadPreference(store, "displayNameQBI", initially: "QBI")
        
        self.footerItems = loadPreference(store, "footerItems", initially: [])
    }
}
