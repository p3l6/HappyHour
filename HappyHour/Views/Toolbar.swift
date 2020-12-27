
import SwiftUI

struct ToolbarItems: CustomizableToolbarContent {
    @EnvironmentObject var model: ItemModel
    @EnvironmentObject var settings: UserSettings
    @State var helpSheetVisible = false
    @State var previewSheetVisible = false
    @State var timerSheetVisible = false
    @State var resetAlertVisible = false
    
    func copyHandler() {
        let text = model.formatted()
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([NSPasteboard.PasteboardType.rtf], owner: nil)
        pasteboard.writeObjects([text])
    }
    
    var body: some CustomizableToolbarContent {
        Group {
            ToolbarItem(id: "preferences", placement: .automatic, showsByDefault: true) {
                Button {
                    NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
                } label: {
                    Label("Preferences", systemImage:"gear")
                }.help("Open Preferences")
            }
            
            ToolbarItem(id: "timer", placement: .automatic, showsByDefault: true) {
                Button {
                    timerSheetVisible = true
                } label: {
                    Label("Focus Timer", systemImage:"timer")
                }
                .help("Start a timer...")
                .popover(isPresented: $timerSheetVisible) {
                    TimerStarter(popupVisible: $timerSheetVisible)
                }
            }
            
            ToolbarItem(id: "showHelp", placement: .automatic, showsByDefault: true) {
                Button {
                    helpSheetVisible = true
                } label: {
                    Label("Help", systemImage:"questionmark.circle")
                }
                .help("Show help...")
                .popover(isPresented: $helpSheetVisible) {
                   HelpView()
                }
            }
            
            ToolbarItem(id: "sendEmail", placement: .automatic, showsByDefault: true) {
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
                }.help("Send formatted standup in an email")
            }
            
            ToolbarItem(id: "reset", placement: .automatic, showsByDefault: true) {
                Button {
                    resetAlertVisible = true
                } label: {
                    Label("Reset", systemImage:"repeat")
                }.alert(isPresented: $resetAlertVisible) {
                    Alert(title: Text("Do you want to reset the lists?"),
                          message: Text("By default, this will move tomorrow's items to planned. Everything else will be lost."),
                          primaryButton: .default(Text("Reset"), action: { model.clear()}),
                          secondaryButton: .cancel())
                }.help("Reset the lists, according to preferences")
            }
            
            ToolbarItem(id: "copy", placement: .automatic, showsByDefault: true) {
                Button(action: copyHandler) {
                    Label("Copy", systemImage:"doc.on.doc")
                }.help("Copy formatted standup to clipboard")
            }
            
            ToolbarItem(id: "preview", placement: .automatic, showsByDefault: true) {
                Button {
                    previewSheetVisible = true
                } label:  {
                    Label("Preview", systemImage:"doc.richtext")
                }
                .help("Preview formatted standup")
                .popover(isPresented: $previewSheetVisible) {
                    VStack {
                        // FIXME: SwiftUI.Text does not support attributed strings at this time
                        Text(model.formatted().string)
                        Button(action: copyHandler) {
                            Label("Copy", systemImage:"doc.on.doc")
                        }.help("Copy formatted standup to clipboard")
                    }.padding()
                }
            }
        }
    }
}
