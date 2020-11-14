
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: UserSettings
    
    var body: some View {
        Form {
            Text("Pull Request URL")
            TextField("https://github.com/user/project/pull/", text: $settings.pullRequestURLprefix)
            Text("Standup email thread address")
            TextField("standup@your-team.com", text: $settings.standupEmail)
            Toggle("Show Focus Timer", isOn: $settings.showFocusTimer)
        }
        .padding(20)
        .frame(width: 350)
    }
}
