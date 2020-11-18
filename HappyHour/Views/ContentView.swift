
import SwiftUI

struct ButtonStyleNoBack: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label.background(Color.clear)
    }
}

struct DropDivider: View {
    let visible: Bool
    var body: some View { Group { if visible { Divider().background(Color.accentColor)}}}
}

struct Trash: View {
    @EnvironmentObject var listModel: ItemModel.List
    let index: Int
    
    var body: some View {
        Button {
            listModel.remove(at: index)
        } label: {
            Label("Trash", systemImage: "trash")
                .labelStyle(IconOnlyLabelStyle())
        }.buttonStyle(ButtonStyleNoBack())
    }
}

struct EditField: View {
    @EnvironmentObject var item: ItemModel.Item
    @EnvironmentObject var model: ItemModel

    var body: some View {
        TextField("new item", text:$item.text, onCommit: {
            print(item.text)
            model.save()
        })
        .padding(.vertical, 3)
        .onExitCommand { NSApp.keyWindow?.makeFirstResponder(nil) }
        .textFieldStyle(PlainTextFieldStyle())
    }
}

struct ListRow: View {
    @EnvironmentObject var model: ItemModel
    @EnvironmentObject var listModel: ItemModel.List
    @EnvironmentObject var item: ItemModel.Item
    @State var hovered = false
    @State var dropTarget = false
    let index: Int
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "rhombus").foregroundColor(.accentColor)
                EditField()
                if hovered { Trash(index: index) }
                Image(systemName: "line.horizontal.3")
                    .onDrag { NSItemProvider(object: DragHelper(text:self.item.text, source: item.id)) }
            }
            .onHover { over in hovered = over }
            
            DropDivider(visible: dropTarget)
        }
        .onDrop(of: DragHelper.type, isTargeted: $dropTarget, perform: performDrop)
    }
    
    func performDrop(itemProviders: [NSItemProvider]) -> Bool {
        return dropHelper(itemProviders) { dragHelper in
            let item = ItemModel.Item(initialText: dragHelper.text)
            listModel.items.insert(item, at: index+1)
            model.remove(id: dragHelper.source)
        }
    }
}

struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        Label(title, systemImage:icon)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 2)
            .padding(.leading, 20)
            .foregroundColor(.accentColor)
    }
}

struct NewItem: View {
    @EnvironmentObject var model: ItemModel
    @EnvironmentObject var listModel: ItemModel.List
    @State var editText: String = ""
    
    var body: some View {
        HStack{
            Image(systemName: "rhombus").foregroundColor(.secondary)
            TextField("new item", text:$editText, onCommit: {
                if editText.count > 0 {
                    listModel.add(editText)
                    print(editText)
                    editText = ""
                    model.save()
                }
            })
            .padding(.vertical, 3)
            .onExitCommand { NSApp.keyWindow?.makeFirstResponder(nil) }
            .textFieldStyle(PlainTextFieldStyle())
        }
    }
}

struct SectionView: View {
    @EnvironmentObject var model: ItemModel
    @EnvironmentObject var listModel: ItemModel.List
    @State var dropTarget = false
    @State var dropTargetFooter = false
    let title: String
    let icon: String
    
    var body: some View {
        Section(header: SectionHeader(title: title, icon: icon).onDrop(of: DragHelper.type, isTargeted: $dropTarget, perform:performDrop),
                footer: NewItem().onDrop(of: DragHelper.type, isTargeted: $dropTargetFooter, perform:performDropFooter)){
            DropDivider(visible: dropTarget)
            
            ForEach(Array(listModel.items.enumerated()), id:\.1.id) { index, item in
                ListRow(index: index).environmentObject(item)
            }
            
            DropDivider(visible: dropTargetFooter)
        }
        .padding(.horizontal)
    }

    func performDrop(itemProviders: [NSItemProvider]) -> Bool {
        return dropHelper(itemProviders) { dragHelper in
            let item = ItemModel.Item(initialText: dragHelper.text)
            listModel.items.insert(item, at: 0)
            model.remove(id: dragHelper.source)
        }
    }
    
    func performDropFooter(itemProviders: [NSItemProvider]) -> Bool {
        return dropHelper(itemProviders) { dragHelper in
            let item = ItemModel.Item(initialText: dragHelper.text)
            listModel.items.append(item)
            model.remove(id: dragHelper.source)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var model: ItemModel
    @EnvironmentObject var settings: UserSettings

    var body: some View {
        Group {
            TimerBar()
            ScrollView {
                SectionView(title:"Planned", icon: "tray").environmentObject(model.planned)
                SectionView(title:"Today", icon: "checkmark.square").environmentObject(model.today)
                SectionView(title:"Tomorrow", icon: "calendar").environmentObject(model.tomorrow)
                SectionView(title:"QBI", icon: "hand.raised").environmentObject(model.qbi)
            }
        }
        .frame(minWidth: 520, maxWidth: .infinity,
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
