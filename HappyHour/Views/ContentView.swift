
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
    let index: Int

    var body: some View {
        HStack{
            Image(systemName: "arrowtriangle.right.fill")
            TextField("new item", text:$item.text, onCommit: {
                print(self.item.text)
                self.model.save()
            })
            .onExitCommand { NSApp.keyWindow?.makeFirstResponder(nil) }
            .textFieldStyle(PlainTextFieldStyle())
            Button {
                listModel.remove(at: index)
            } label: {
                Label("Trash", systemImage: "trash").labelStyle(IconOnlyLabelStyle())
            }.buttonStyle(ButtonStyleNoBack())
        }
    }
}

struct NewItem: View {
    @EnvironmentObject var model: ItemModel
    @EnvironmentObject var listModel: ItemModel.List
    @State var editText: String = ""
    
    var body: some View {
        TextField("new item", text:self.$editText, onCommit: {
            if self.editText.count > 0 {
                self.listModel.add(self.editText)
                print(self.editText)
                self.editText = ""
                self.model.save()
            }
        })
        .onExitCommand { NSApp.keyWindow?.makeFirstResponder(nil) }
        .textFieldStyle(PlainTextFieldStyle())
    }
}

struct SectionView: View {
    @EnvironmentObject var listModel: ItemModel.List
    let title: String
    
    var body: some View {
        Section(header: Text(title),
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

    var body: some View {
        Group {
            Button {
                self.helpSheetVisible = true
            } label: {
                Label("Help", systemImage:"questionmark.circle")
            }.popover(isPresented: self.$helpSheetVisible) {
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
                    service.perform(withItems: [self.model.formatted()])
                }
            } label:  {
                Label("Send", systemImage:"paperplane")
            }
            Button { self.model.clear() } label: {
                Label("Reset", systemImage:"repeat")
            }
            Button {
                let text = self.model.formatted()
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
            List {
                SectionView(title:"Planned").environmentObject(model.planned)
                SectionView(title:"Today").environmentObject(model.today)
                SectionView(title:"Tomorrow").environmentObject(model.tomorrow)
                SectionView(title:"QBI").environmentObject(model.qbi)
            }
            if settings.showFocusTimer {
                TimerBar()
            }
        }
        .padding()
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
            .environmentObject(self.sampleData())
            .environmentObject(TaskTimer())
            .environmentObject(UserSettings())
    }
}
