
import SwiftUI

struct ButtonStyleNoBack: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label.background(Color.clear)
    }
}

struct ListRow: View {
    @EnvironmentObject var model: ItemModel
    @EnvironmentObject var listModel: ItemModel.List
    @EnvironmentObject var item: ItemModel.Item
    @State var hovered = false
    let index: Int

    var body: some View {
        HStack{
            Image(systemName: "rhombus")
                .foregroundColor(.accentColor)
            TextField("new item", text:$item.text, onCommit: {
                print(item.text)
                model.save()
            })
            .padding(1)
            .onExitCommand { NSApp.keyWindow?.makeFirstResponder(nil) }
            .textFieldStyle(PlainTextFieldStyle())
            if hovered {
                Button {
                    listModel.remove(at: index)
                } label: {
                    Label("Trash", systemImage: "trash")
                        .labelStyle(IconOnlyLabelStyle())
                }.buttonStyle(ButtonStyleNoBack())
            }
        }
        .onHover { over in
            hovered = over
        }
    }
}

struct NewItem: View {
    @EnvironmentObject var model: ItemModel
    @EnvironmentObject var listModel: ItemModel.List
    @State var editText: String = ""
    
    var body: some View {
        HStack{
            Image(systemName: "rhombus")
                .foregroundColor(.secondary)
            TextField("new item", text:$editText, onCommit: {
                if editText.count > 0 {
                    listModel.add(editText)
                    print(editText)
                    editText = ""
                    model.save()
                }
            })
            .onExitCommand { NSApp.keyWindow?.makeFirstResponder(nil) }
            .textFieldStyle(PlainTextFieldStyle())
        }
    }
}

struct SectionView: View {
    @EnvironmentObject var listModel: ItemModel.List
    let title: String
    let icon: String
    
    var body: some View {
        Section(header: Label(title, systemImage:icon).foregroundColor(.accentColor),
                footer: NewItem()){
            ForEach(Array(listModel.items.enumerated()), id:\.1.id) { index, item in
                ListRow(index: index)
                    .environmentObject(item)
            }
            .onMove { indices, newOffset in
                listModel.items.move(fromOffsets: indices, toOffset: newOffset)
            }
        }
    }
}

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

struct ContentView: View {
    @EnvironmentObject var model: ItemModel
    @EnvironmentObject var settings: UserSettings

    var body: some View {
        Group {
            TimerBar()
            List {
                SectionView(title:"Planned", icon: "tray").environmentObject(model.planned)
                SectionView(title:"Today", icon: "checkmark.square").environmentObject(model.today)
                SectionView(title:"Tomorrow", icon: "calendar").environmentObject(model.tomorrow)
                SectionView(title:"QBI", icon: "hand.raised").environmentObject(model.qbi)
            }
            .listStyle(DefaultListStyle())
        }
        .frame(minWidth: 450, maxWidth: .infinity,
               minHeight: 425, maxHeight: .infinity,
               alignment: .topLeading)
        .navigationTitle(settings.storageFileName)
        .toolbar { ToolbarItems() }
    }
}


struct ContentView_Previews: PreviewProvider {
    static func sampleData() -> ItemModel {
        let model = ItemModel()
        model.planned.add("Thing that was planned")
        model.today.add("Thing that was done")
        model.today.add("Another thing done")
        model.tomorrow.add("Something for tomorrow")
        model.qbi.add("A really long thing that was done so that it won't all fit in one line at the default width and need to wrap.")
        return model
    }
    
    static var previews: some View {
        ContentView()
            .environmentObject(sampleData())
            .environmentObject(TaskTimer())
            .environmentObject(UserSettings())
    }
}
