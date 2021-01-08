
import SwiftUI

struct HelpView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("The Copy action will format the sections suitable for email,")
            Text("and place them on the clipboard")
            Divider()
            Text("You May specify PRs with either of the follwing formats:")
            Text("PR 1234 | PR1234")
            Text("And they will be automatically linked, using the URL set in preferences.")
            Divider()
            Group {
                Text("You May specify jira issues with the follwing format:")
                Text("ABC-1234")
                Text("And they will be automatically linked, using the URL and prefixes set in preferences.")
                Divider()
            }
            Text("Resetting the form clears all sections,")
            Text("except that the contents from tomorrow are moved to planned")
        }.padding()
    }
}

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView()
    }
}
