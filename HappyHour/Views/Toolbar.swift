
import SwiftUI

struct TBPreferences: View {
    var body: some View {
        Button {
            NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        } label: {
            Label("Preferences", systemImage:"gear")
        }.help("Open Preferences")
    }
}

struct TBTimer: View {
    @State var timerSheetVisible = false
    var body: some View {
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
}

struct TBHelp: View {
    @State var helpSheetVisible = false
    var body: some View {
        Button {
            helpSheetVisible = true
        } label: {
            Label("Help", systemImage:"questionmark.circle")
        }
        .help("Show help...")
        .popover(isPresented: $helpSheetVisible, arrowEdge: .bottom) {
           HelpView()
        }
    }
}

struct TBSendEmail: View {
    @EnvironmentObject var model: ItemModel
    @EnvironmentObject var settings: UserSettings
    var body: some View {
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
}

struct TBReset: View {
    @EnvironmentObject var model: ItemModel
    @State var resetAlertVisible = false
    var body: some View {
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
}

struct TBCopy: View {
    @EnvironmentObject var model: ItemModel

    func copyHandler() {
        let text = model.formatted()
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([NSPasteboard.PasteboardType.rtf], owner: nil)
        pasteboard.writeObjects([text])
    }
    
    var body: some View {
        Button(action: copyHandler) {
            Label("Copy", systemImage:"doc.on.doc")
        }.help("Copy formatted standup to clipboard")
    }
}

struct TBPreview: View {
    @EnvironmentObject var model: ItemModel
    @State var previewSheetVisible = false
    
    func copyHandler() {
        let text = model.formatted()
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([NSPasteboard.PasteboardType.rtf], owner: nil)
        pasteboard.writeObjects([text])
    }
    
    var body: some View {
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

struct ToolbarItems: CustomizableToolbarContent {
    
    var body: some CustomizableToolbarContent {
        Group {
            ToolbarItem(id: "copy", placement: .automatic, showsByDefault: true) { TBCopy() }
            ToolbarItem(id: "reset", placement: .automatic, showsByDefault: true) { TBReset() }
            ToolbarItem(id: "preferences", placement: .automatic, showsByDefault: true) { TBPreferences() }
            ToolbarItem(id: "showHelp", placement: .automatic, showsByDefault: true) { TBHelp() }
            ToolbarItem(id: "preview", placement: .automatic, showsByDefault: true) { TBPreview() }
            
            ToolbarItem(id: "timer", placement: .automatic, showsByDefault: false) { TBTimer() }
            ToolbarItem(id: "sendEmail", placement: .automatic, showsByDefault: false) { TBSendEmail() }
        }
    }
}
