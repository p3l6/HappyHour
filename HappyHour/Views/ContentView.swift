
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
    @State var dropTarget = false
    let index: Int
    
    var body: some View {
        VStack {
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
            Image(systemName: "line.horizontal.3")
                .onDrag {
                    let x =  NSItemProvider(object: Thing(text:self.item.text, source: item.id))
                    print(x.registeredTypeIdentifiers)
                    return x
                }
        }
        .onHover { over in
            hovered = over
        }
            if dropTarget {
                Divider()
            }
        }
        .onDrop(of: [kUTTypeData as String], isTargeted: $dropTarget, perform:{ips in performDrop3(itemProviders:ips, after: index)})
    }
    
    func performDrop3(itemProviders: [NSItemProvider], after: Int) -> Bool {
        guard
            let itemProvider = itemProviders.first
        else { return false }
        
        itemProvider.loadObject(ofClass: Thing.self, completionHandler: { thingarg, foo in
            guard
                let thing = thingarg as? Thing
            else { return }
            let item = ItemModel.Item(initialText: thing.text)
            DispatchQueue.main.async {
                self.listModel.items.insert(item, at: after+1)
                model.remove(id: thing.source)
            }
        }
        )
        return true
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

class Thing: NSObject, NSItemProviderWriting, NSItemProviderReading, Codable {
    //TODO: rename at least. combine with Item?
    static var readableTypeIdentifiersForItemProvider = [kUTTypeData as String]
    static var writableTypeIdentifiersForItemProvider = [kUTTypeData as String]
    
    let text: String
    let source: UUID
    
    required init(text: String, source: UUID) {
        self.text = text
        self.source = source
    }
    
    static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> Self {
        let decoder = JSONDecoder()
        do {
            let myJSON = try decoder.decode(Self.self, from: data)
            return myJSON
        } catch {
            fatalError("Err")
        }
    }
    
    func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
        let progress = Progress(totalUnitCount: 100)
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(self)
            progress.completedUnitCount = 100
            completionHandler(data, nil)
        } catch {
            
            completionHandler(nil, error)
        }
        return progress
    }
}

struct SectionView: View {
    @EnvironmentObject var model: ItemModel
    @EnvironmentObject var listModel: ItemModel.List
    @State var dropTarget = false
    let title: String
    let icon: String
    
    var body: some View {
        Section(header: Label(title, systemImage:icon).foregroundColor(.accentColor).onDrop(of: [kUTTypeData as String], isTargeted: $dropTarget, perform:performDrop2),
                footer: NewItem()){ // drop on footer at end
            if dropTarget {
                Divider()
            }
            ForEach(Array(listModel.items.enumerated()), id:\.1.id) { index, item in
                ListRow(index: index)
                    .environmentObject(item)
                    
            }
        }
    }

    //TODO: Extract drop functions to a file?
    func performDrop2(itemProviders: [NSItemProvider]) -> Bool {
        guard
            let itemProvider = itemProviders.first
        else { return false }
        
        itemProvider.loadObject(ofClass: Thing.self, completionHandler: { thingarg, foo in
            guard
                let thing = thingarg as? Thing
            else { return }
            let item = ItemModel.Item(initialText: thing.text)
            DispatchQueue.main.async {
                self.listModel.items.insert(item, at: 0)
                model.remove(id: thing.source)
            }
        }
        )
        return true
    }
    
}

struct ContentView: View {
    @EnvironmentObject var model: ItemModel
    @EnvironmentObject var settings: UserSettings

    var body: some View {
        Group {
            TimerBar()
            // Explain why lists dont work... ie text fields are broken, tab loop, edititng, selecting.
            // style is retrrictive.
                // so, custtom drag and drop behavior has been created
            SectionView(title:"Planned", icon: "tray").environmentObject(model.planned)
            SectionView(title:"Today", icon: "checkmark.square").environmentObject(model.today)
            SectionView(title:"Tomorrow", icon: "calendar").environmentObject(model.tomorrow)
            SectionView(title:"QBI", icon: "hand.raised").environmentObject(model.qbi)
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
