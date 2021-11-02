
import SwiftUI

struct DropDivider: View {
    let visible: Bool
    var body: some View {
        Divider()
            .background(Color.accentColor)
            .isHidden(!visible)
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
        }.buttonStyle(BorderlessButtonStyle())
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
                MultilineTextField("blank", text:$item.text)
                    .padding(1)
                    .onExitCommand { NSApp.keyWindow?.makeFirstResponder(nil) }
                Trash(index: index)
                    .font(Font.system(.title3))
                    .isHidden(!hovered)
            }
            .onDrag { NSItemProvider(object: DragHelper(item.id)) }
            .onHover { over in hovered = over }
            
            DropDivider(visible: dropTarget)
        }
        .onDrop(of: DragHelper.type, isTargeted: $dropTarget, perform: performDrop)
    }
    
    func performDrop(itemProviders: [NSItemProvider]) -> Bool {
        return dropHelper(itemProviders) { dragHelper in
            model.move(id: dragHelper.source, to: listModel, at: index+1)
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
            .padding(.top)
            .foregroundColor(.accentColor)
            .font(Font.system(.title2))
    }
}

struct NewItem: View {
    @EnvironmentObject var listModel: ItemModel.List
    @State var editText: String = ""
    
    var body: some View {
        HStack{
            Image(systemName: "rhombus")
                .foregroundColor(.secondary)
                .font(Font.system(.title3))
            MultilineTextField("add item", text:$editText, onCommit: {
                if editText.count > 0 {
                    listModel.add(editText)
                    editText = ""
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    NSApp.keyWindow?.recalculateKeyViewLoop()
                }
            })
            .padding(1)
            .onExitCommand { NSApp.keyWindow?.makeFirstResponder(nil) }
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
        Section(header: SectionHeader(title: title, icon: icon)
                    .onDrop(of: DragHelper.type, isTargeted: $dropTarget, perform:performDrop),
                footer: NewItem()
                    .onDrop(of: DragHelper.type, isTargeted: $dropTargetFooter, perform:performDropFooter)){
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
            model.move(id: dragHelper.source, to: listModel, at: 0)
        }
    }
    
    func performDropFooter(itemProviders: [NSItemProvider]) -> Bool {
        return dropHelper(itemProviders) { dragHelper in
            model.move(id: dragHelper.source, to: listModel, at: Int.max)
        }
    }
}

struct Footer: View {
    @EnvironmentObject var model: ItemModel
    @EnvironmentObject var settings: UserSettings

    func binding(for key: String) -> Binding<ItemModel.FooterStatus> {
        return Binding(get: {
            return model.footer[key] ?? .no
        }, set: {
            model.footer[key] = $0
        })
    }
    
    func options() -> some View {
        Group {
            Text("Yes").tag(ItemModel.FooterStatus.yes)
            Text("Maybe").tag(ItemModel.FooterStatus.maybe)
            Text("No").tag(ItemModel.FooterStatus.no)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(settings.footerItems, id: \.self) { item in
                Picker(selection: binding(for: item),
                       label: Label(item, systemImage:"questionmark.diamond")
                        .foregroundColor(.accentColor)
                ) { options() }
            }
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var model: ItemModel
    @EnvironmentObject var settings: UserSettings

    var body: some View {
        VStack {
            ScrollView {
                SectionView(title:settings.displayNamePlanned, icon: "tray")
                    .environmentObject(model.planned)
                SectionView(title:settings.displayNameToday, icon: "checkmark.square")
                    .environmentObject(model.today)
                SectionView(title:settings.displayNameTomorrow, icon: "calendar")
                    .environmentObject(model.tomorrow)
                SectionView(title:settings.displayNameQBI, icon: "hand.raised")
                    .environmentObject(model.qbi)
            }
            if !settings.footerItems.isEmpty {
                Divider()
                Footer().padding()
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
    
    static func sampleSettings() -> UserSettings {
        let settings = UserSettings(store: nil)
        settings.footerItems = ["Question 1?"]
        return settings
    }
    
    static var previews: some View {
        ContentView()
            .environmentObject(sampleData())
            .environmentObject(sampleSettings())
    }
}
