
import SwiftUI

struct HelpSection: View {
    let title: String
    let image: String
    let text: String
    var body: some View {
        VStack {
            Image(systemName: image).font(Font.system(.largeTitle))
                .padding()
            Text(text).padding()
        }
        .tabItem {
            Text(title)
        }
    }
}

struct HelpView: View {
    var body: some View {
        TabView {
            HelpSection(title: "Copy",
                        image: "doc.on.doc",
                        text: """
The copy toolbar action will format the sections as rich text,
suitable for pasting into email or slack, and put it on the clipboard.

The Planned section is ignored for this, you should treat it as scratch space.
""")

            HelpSection(title: "Github",
                        image: "arrow.triangle.pull",
                        text: """
Links to Github pull requests will be automatically created in the
formatted standup.

You must specify PRs with either of the following formats: PR 1234 or PR1234

The github base URL must be set in preferences.
Note 1: The github base URL should end with a slash.
""")

            HelpSection(title: "Jira",
                        image: "ant.circle",
                        text: """
Links to Jira issues will be automatically created in the
formatted standup.

You must specify jira issues with the follwing format: ABC-1234

The jira base URL and prefixes must set in preferences.
Note 1: Multiple prefixes in preferences should be separated by spaces, ie "ABC BUG".
Note 2: The jira base URL should end with a slash.
""")
            
            HelpSection(title: "Daily Reset",
                        image: "repeat",
                        text: """
By default, resetting the form discards all items except
the contents of Tomorrow, which are moved to Planned.

This is configurable in settings. Any section can be kept,
discarded, or moved to Planned.
""")
            
            HelpSection(title: "Preview",
                        image: "doc.richtext",
                        text: """
The preview toolbar action attempts to display the formatted standup.

However, due to current limitations in the available GUI API this app
is using, bold text / links cannot be rendered, and this is not an important
enough feature to work around it.

As with most mac apps, you can customize to toolbar
(by right clicking on it) to remove this button.
""")
            
            HelpSection(title: "Email",
                        image: "paperplane",
                        text: """
The preview toolbar action launches an email draft with the formatted standup.

The subject will be autofilled with today's date, and if an email address
is set in preferences, it will be used in the to: field.

However, this doesn't handle replying to an existing thread,
which seems to be the case most of the time.

This toolbar button is hidden by default, but as most mac apps,
you can customize to toolbar (by right clicking on it) to add this button.
""")
            
            
        }
        .padding()
        .frame(minWidth: 250, minHeight: 350)
    }
}

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView()
    }
}
