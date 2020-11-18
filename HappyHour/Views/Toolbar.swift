
import SwiftUI

struct ToolbarItems: View {
    @EnvironmentObject var model: ItemModel
    @EnvironmentObject var settings: UserSettings
    @State var helpSheetVisible = false
    @State var timerSheetVisible = false
    @State var resetAlertVisible = false

    var body: some View {
        Group {
            Button {
                NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
            } label: {
                Label("Preferences", systemImage:"gear")
            }
            
            Button {
                timerSheetVisible = true
            } label: {
                Label("Focus Timer", systemImage:"timer")
            }.popover(isPresented: $timerSheetVisible) {
                TimerStarter(popupVisible: $timerSheetVisible)
            }
            //TODO: tooltips on these buttons?
            
            Button {
                helpSheetVisible = true
            } label: {
                Label("Help", systemImage:"questionmark.circle")
            }.popover(isPresented: $helpSheetVisible) {
               HelpView()
            }
            
            Button {
                if let service = NSSharingService(named: NSSharingService.Name.composeEmail) {
                    let today = Date()
                    let f = DateFormatter()
                    f.dateFormat = "yyyy-MM-dd"
                    if settings.standupEmail.count > 0 {
                        service.recipients = [settings.standupEmail]
                    }
                    service.subject = "\(f.string(from: today)) Standup"
                    service.perform(withItems: [model.formatted()])
                }
            } label:  {
                Label("Send", systemImage:"paperplane")
            }
            
            Button {
                resetAlertVisible = true
            } label: {
                Label("Reset", systemImage:"repeat")
            }.alert(isPresented: $resetAlertVisible) {
                Alert(title: Text("Do you want to reset the lists?"),
                      message: Text("By default, this will move tomorrow's items to planned. Everything else will be lost."),
                      primaryButton: .default(Text("Reset"), action: { model.clear()}),
                      secondaryButton: .cancel())
            }
            
            Button {
                let text = model.formatted()
                let pasteboard = NSPasteboard.general
                pasteboard.declareTypes([NSPasteboard.PasteboardType.rtf], owner: nil)
                pasteboard.writeObjects([text])
            } label:  {
                Label("Copy", systemImage:"doc.on.doc")
            }
        }
    }
}
struct Toolbar_Previews: PreviewProvider {
    static var previews: some View {
        ToolbarItems()
    }
}
