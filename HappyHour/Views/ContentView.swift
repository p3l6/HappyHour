
import SwiftUI

// TODO: Remove this hack when swiftui allows disabling focus ring for specific TextFields
// Then, disable them for all the text fields on this page
// https://stackoverflow.com/a/60290791
// This disables all focus rings for all text fields in the whole app
extension NSTextField {
    open override var focusRingType: NSFocusRingType {
        get { .none }
        set { }
    }
}

struct ButtonStyleNoBack: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label.background(Color.clear)
    }
}

struct DropDivider: View {
    let visible: Bool
    var body: some View {
        Group {
            if visible {
                Divider().background(Color.accentColor)
            }
        }
    }
}

struct Trash: View {
    @EnvironmentObject var listModel: ItemModel.List
    let index: Int
    
    var body: some View {
        Button {
            listModel.remove(at: index)
        } label: {
            Label("Trash", systemImage: "trash").labelStyle(IconOnlyLabelStyle())
        }.buttonStyle(ButtonStyleNoBack())
    }
}

struct EditField: View {
    @EnvironmentObject var item: ItemModel.Item
    @State private var editing = false
    @Binding var outline: Bool

    var body: some View {
        TextField("blank", text:$item.text, onEditingChanged: { editing = $0 })
        .padding(5)
        .onExitCommand { NSApp.keyWindow?.makeFirstResponder(nil) }
        .textFieldStyle(PlainTextFieldStyle())
        .background(RoundedRectangle(cornerRadius: 10, style: .continuous)
            .stroke(editing ? Color.accentColor :
                   (outline ? Color.gray : Color.clear), lineWidth: 2))
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
                Image(systemName: "rhombus")
                    .foregroundColor(.accentColor)
                    .font(Font.system(.title3))
                    .onDrag { NSItemProvider(object: DragHelper(text:self.item.text, source: item.id)) }
                EditField(outline: $hovered)
                if hovered {
                    Trash(index: index)
                        .font(Font.system(.title3))
                }
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
            .font(Font.system(.title2))
    }
}

struct NewItem: View {
    @EnvironmentObject var listModel: ItemModel.List
    @State var editText: String = ""
    @State private var editing = false
    
    var body: some View {
        HStack{
            Image(systemName: "rhombus")
                .foregroundColor(.secondary)
                .font(Font.system(.title3))
            TextField("add item", text:$editText, onEditingChanged: { editing = $0 }, onCommit: {
                if editText.count > 0 {
                    listModel.add(editText)
                    editText = ""
                }
            })
            .padding(5)
            .onExitCommand { NSApp.keyWindow?.makeFirstResponder(nil) }
            .textFieldStyle(PlainTextFieldStyle())
            .background(RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(editing ? Color.accentColor : Color.clear, lineWidth: 2))
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
        Section(header:SectionHeader(title: title, icon: icon)
                    .onDrop(of: DragHelper.type, isTargeted: $dropTarget, perform:performDrop),
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
        VStack {
            TimerBar()
            ScrollView {
                SectionView(title:"Planned", icon: "tray").environmentObject(model.planned)
                SectionView(title:"Today", icon: "checkmark.square").environmentObject(model.today)
                SectionView(title:"Tomorrow", icon: "calendar").environmentObject(model.tomorrow)
                SectionView(title:"QBI", icon: "hand.raised").environmentObject(model.qbi)
            }
        }
        .frame(minWidth: 350, idealWidth: 450, maxWidth: 1000,
               minHeight: 450, idealHeight: 550, maxHeight: .infinity,
               alignment: .topLeading)
        .navigationTitle(settings.storageFileName)
        .toolbar(id: "mainToolbar") { ToolbarItems() }
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
