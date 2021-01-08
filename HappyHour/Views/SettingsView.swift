
import SwiftUI

struct MainSettings: View {
    @EnvironmentObject var settings: UserSettings

    var body: some View {
        Form {
            Text("Pull Request URL")
            TextField("https://github.com/user/project/pull/", text: $settings.pullRequestURLprefix)
            
            Text("Jira Issue URL")
            TextField("https://someone.atlassian.net/browse/", text: $settings.jiraURLprefix)
            Text("Jira Project Prefixes (space separated)")
            TextField("ABC BUG", text: $settings.jiraProjectprefixes)
            
            Text("Standup email thread address")
            TextField("standup@your-team.com", text: $settings.standupEmail)
            Button() {
                if let filePath = Bundle.main.url(forResource: "HappyHour", withExtension: "alfredworkflow") {
                    NSWorkspace.shared.open(filePath)
                }
            } label: {
                Label("Install alfred workflow", systemImage:"square.grid.2x2.fill")
            }
        }
    }
}

struct ResetSettings: View {
    @EnvironmentObject var settings: UserSettings
    
    func options() -> some View {
        Group {
            Text("Discard items").tag(UserSettings.ResetBehavior.discard)
            Text("Move items to planned").tag(UserSettings.ResetBehavior.toPlanned)
            Text("Keep items").tag(UserSettings.ResetBehavior.keep)
        }
    }
    
    var body: some View {
        Form {
            Section(header: Text("Item behavior for reset action:")) {
                Picker(selection: $settings.resetBehaviorPlanned,
                       label: Label("Planned", systemImage:"tray")) { options() }
                
                Picker(selection: $settings.resetBehaviorToday,
                       label: Label("Today", systemImage:"checkmark.square")) { options() }
                
                Picker(selection: $settings.resetBehaviorTomorrow,
                       label: Label("Tomorrow", systemImage:"calendar")) { options() }
                
                Picker(selection: $settings.resetBehaviorQbi,
                       label: Label("QBI", systemImage:"hand.raised")) { options() }
            }
        }
    }
}

struct SettingsView: View {
    private enum Tabs: Hashable {
        case general, reset
    }
    
    var body: some View {
        TabView( ) {
            MainSettings()
                .tabItem {Label("General", systemImage: "gear")}
                .tag(Tabs.general)
            ResetSettings()
                .tabItem {Label("Daily Reset", systemImage: "repeat")}
                .tag(Tabs.reset)
        }
        .padding(20)
        .frame(width: 350)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            MainSettings()
            ResetSettings()
        }
        .padding(20)
        .frame(width: 350)
        .environmentObject(UserSettings())
    }
}
