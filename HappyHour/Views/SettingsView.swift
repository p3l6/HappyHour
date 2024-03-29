
import SwiftUI

struct MainSettings: View {
    @EnvironmentObject var settings: UserSettings

    var body: some View {
        Form {
            Toggle(isOn: $settings.formatEmptySections) {
                Label("Include empty sections in report", systemImage: "questionmark.square.dashed").labelStyle(TitleOnlyLabelStyle())
            }
            
            TextField("Pull Request URL",
                      text: $settings.pullRequestURLprefix,
                      prompt: Text("https://github.com/user/project/pull/"))
            
            TextField("Jira Issue URL",
                      text: $settings.jiraURLprefix,
                      prompt: Text("https://someone.atlassian.net/browse/"))

            TextField("Jira Project Prefixes (space separated)",
                      text: $settings.jiraProjectprefixes,
                      prompt: Text("ABC BUG"))
            
            TextField("Standup email thread address",
                      text: $settings.standupEmail,
                      prompt: Text("standup@your-team.com"))
                      
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

struct DisplaySettings: View {
    @EnvironmentObject var settings: UserSettings
    
    var body: some View {
        Form {
            Section(header: Text("Heading display names:")) {
                Picker(selection: $settings.displayNamePlanned,
                       label: Label(settings.displayNamePlanned, systemImage:"tray")) {
                    Text("Planned").tag("Planned")
                    Text("To Do").tag("To Do")
                }
                
                Picker(selection: $settings.displayNameToday,
                       label: Label(settings.displayNameToday, systemImage:"checkmark.square")) {
                    Text("Today").tag("Today")
                    Text("Yesterday").tag("Yesterday")
                    Text("Completed").tag("Completed")
                }
                
                Picker(selection: $settings.displayNameTomorrow,
                       label: Label(settings.displayNameTomorrow, systemImage:"calendar")) {
                    Text("Tomorrow").tag("Tomorrow")
                    Text("Today").tag("Today")
                    Text("Up Next").tag("Up Next")
                }
                
                Picker(selection: $settings.displayNameQBI,
                       label: Label(settings.displayNameQBI, systemImage:"hand.raised")) {
                    Text("QBI").tag("QBI")
                    Text("Blocks").tag("Blocks")
                    Text("Distractors").tag("Distractors")
                    Text("Blocks | Distractors").tag("Blocks | Distractors")
                }
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
                       label: Label(settings.displayNamePlanned, systemImage:"tray")) { options() }
                
                Picker(selection: $settings.resetBehaviorToday,
                       label: Label(settings.displayNameToday, systemImage:"checkmark.square")) { options() }
                
                Picker(selection: $settings.resetBehaviorTomorrow,
                       label: Label(settings.displayNameTomorrow, systemImage:"calendar")) { options() }
                
                Picker(selection: $settings.resetBehaviorQbi,
                       label: Label(settings.displayNameQBI, systemImage:"hand.raised")) { options() }
            }
        }
    }
}

struct FooterSettings: View {
    @EnvironmentObject var settings: UserSettings
    @State var newItem: String = ""
    
    var body: some View {
        VStack {
            Text("A list of Yes/No/Maybe questions at the end of the report")
            List {
                ForEach(Array(settings.footerItems.enumerated()), id:\.1.self) { index, item in
                    HStack {
                        Button {
                            settings.footerItems.remove(at: index)
                        } label: {
                            Label("Trash", systemImage: "trash").labelStyle(IconOnlyLabelStyle())
                        }
                        Text(item)
                    }
                }
                Divider()
                HStack {
                    TextField("Is Jira up to date?", text:$newItem)
                    Button {
                        settings.footerItems.append(newItem)
                        newItem = ""
                    } label: {
                        Label("Add", systemImage: "plus")
                    }.disabled(newItem.isEmpty)
                }
            }
        }
    }
}

struct SettingsView: View {
    private enum Tabs: Hashable {
        case general, display, footer, reset
    }
    
    var body: some View {
        TabView( ) {
            MainSettings()
                .tabItem {Label("General", systemImage: "gear")}
                .tag(Tabs.general)
            DisplaySettings()
                .tabItem {Label("Display", systemImage: "macwindow") }
                .tag(Tabs.display)
            FooterSettings()
                .tabItem {Label("Footer", systemImage: "questionmark.diamond") }
                .tag(Tabs.footer)
            ResetSettings()
                .tabItem {Label("Daily Reset", systemImage: "repeat")}
                .tag(Tabs.reset)
        }
        .padding(20)
        .frame(width: 600)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            MainSettings()
            ResetSettings()
            FooterSettings()
        }
        .padding(20)
        .frame(width: 400)
        .environmentObject(UserSettings(store: nil))
    }
}
