
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

    var body: some View {
        HStack{
            Image(systemName: "arrowtriangle.right.fill")
            TextField("new item", text:$item.text, onCommit: {
                print(self.item.text)
                self.model.save()
            })
            .onExitCommand(perform: { NSApp.keyWindow?.makeFirstResponder(nil) })
            .textFieldStyle(PlainTextFieldStyle())
            Button {
                self.listModel.moveUp(self.item.id)
            } label: {
                Label("Up", systemImage: "arrow.up").labelStyle(IconOnlyLabelStyle())
            }.buttonStyle(ButtonStyleNoBack())
            Button {
                    self.listModel.moveDown(self.item.id)
            } label: {
                Label("Down", systemImage: "arrow.down").labelStyle(IconOnlyLabelStyle())
            }.buttonStyle(ButtonStyleNoBack())
            Button {
                self.listModel.remove(self.item.id)
            } label: {
                Label("Trash", systemImage: "trash").labelStyle(IconOnlyLabelStyle())
            }.buttonStyle(ButtonStyleNoBack())
        }
    }
}

struct List: View {
    @EnvironmentObject var model: ItemModel
    @EnvironmentObject var listModel: ItemModel.List
    @State var editText: String = ""
    let title: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title).bold()
            ForEach(self.listModel.items) { item in
                ListRow().environmentObject(item)
            }
            TextField("new item", text:self.$editText, onCommit: {
                if self.editText.count > 0 {
                    self.listModel.add(self.editText)
                    print(self.editText)
                    self.editText = ""
                    self.model.save()
                }
            })
            .onExitCommand(perform: { NSApp.keyWindow?.makeFirstResponder(nil) })
            .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(Edge.Set.horizontal)
    }
}

struct HelpWidget: View {
    @State var helpSheetVisible = false
    
    var body: some View {
        Button(action: { self.helpSheetVisible = true }) {
            Label("Help", systemImage:"questionmark.circle")
        }.popover(isPresented: self.$helpSheetVisible) {
            VStack(alignment: .leading) {
                Text("The Copy action will format the sections suitable for email,")
                Text("and place them on the clipboard")
                Divider()
                Text("You May specify PRs with either of the follwing formats:")
                Text("PR 1234 | PR1234")
                Text("And they will be automatically linked, using the URL set in preferences.")
                Divider()
                Text("Resetting the form clears all sections,")
                Text("except that the contents from tomorrow are moved to planned")
            }.padding()
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var model: ItemModel
    @EnvironmentObject var settings: UserSettings

    var body: some View {
        VStack {
            Text(settings.storageFileName).bold()
            List(title:"Planned").environmentObject(model.planned)
            List(title:"Today").environmentObject(model.today)
            List(title:"Tomorrow").environmentObject(model.tomorrow)
            List(title:"QBI").environmentObject(model.qbi)
            Spacer().layoutPriority(1)
            if settings.showFocusTimer {
                TimerBar()
            }
        }
        .padding()
        .frame(minWidth: 550, maxWidth: .infinity,
               minHeight: 625, maxHeight: .infinity,
               alignment: .topLeading)
        .toolbar {
            HelpWidget()
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
    }
}
