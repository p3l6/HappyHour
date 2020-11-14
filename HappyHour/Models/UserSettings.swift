
import Foundation

private func loadPreference<T>(_ name: String, initially: T) -> T {
    if let pref = UserDefaults.standard.object(forKey: "showFocusTimer") as? T {
        return pref
    }
    return initially
}

class UserSettings: ObservableObject {
    // @AppStorage ???? Neat, is that new?
    
    @Published var showFocusTimer: Bool {
        didSet { UserDefaults.standard.set(showFocusTimer, forKey: "showFocusTimer") }
    }
    
    @Published var pullRequestURLprefix: String {
        didSet { UserDefaults.standard.set(pullRequestURLprefix, forKey: "pullRequestURLprefix") }
    }
    
    @Published var standupEmail: String {
        didSet { UserDefaults.standard.set(standupEmail, forKey: "standupEmail") }
    }
    
    init() {
        self.showFocusTimer = loadPreference("showFocusTimer", initially: true)
        self.pullRequestURLprefix = loadPreference("pullRequestURLprefix", initially: "")
        self.standupEmail = loadPreference("standupEmail", initially: "")
    }
}
