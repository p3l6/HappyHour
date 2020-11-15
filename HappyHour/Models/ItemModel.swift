
import Foundation
import AppKit

final class ItemModel: ObservableObject {
    typealias ItemIdentifier = Int
    typealias List = [Item]
    typealias ListKeyPath = ReferenceWritableKeyPath<ItemModel,List>
    
    final class Item: ObservableObject, Identifiable {
        static var permanumber = 0
        
        let id: ItemIdentifier
        var text: String
        
        init(initialText: String) {
            id = Item.permanumber
            Item.permanumber += 1
            text = initialText
        }
    }

    @Published var planned: List
    @Published var today: List
    @Published var tomorrow: List
    @Published var qbi: List
    
    let filename: String?
    
    static func dataDirectory() -> URL {
        var dir: URL?
        do {
            dir = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            dir = dir?.appendingPathComponent("dev.pwxn.HappyHour")
        }
        catch {
            // TODO: what to do here? quit with a message?
        }
        return dir!
    }
    
    init(filename: String) {
        self.filename = filename
        let diskData = DiskData.load(name:filename)
        
        planned = diskData.planned?.map { Item(initialText: $0) } ?? []
        today = diskData.today?.map { Item(initialText: $0) } ?? []
        tomorrow = diskData.tomorrow?.map { Item(initialText: $0) } ?? []
        qbi = diskData.qbi?.map { Item(initialText: $0) } ?? []
    }
    
    init() {
        filename = nil
        planned = []
        today = []
        tomorrow = []
        qbi = []
    }
    
    func save() {
        guard let filename = filename else { return }
        
        let data = DiskData(
            planned: planned.map { $0.text },
            today: today.map { $0.text },
            tomorrow: tomorrow.map { $0.text },
            qbi: qbi.map { $0.text }
        )
        data.save(name: filename)
    }
    
    func clear() {
        planned = tomorrow
        today = []
        tomorrow = []
        qbi = []
        self.save()
    }
    
    func item(_ x: ItemIdentifier, keyPath: ListKeyPath) -> Item {
        let index = self[keyPath:keyPath].firstIndex(where: {x==$0.id})!
        return today[index]
    }
    
    func remove(_ x: ItemIdentifier, keyPath: ListKeyPath) {
        //TODO: there may be a more efficient way and a filter
        self[keyPath:keyPath].removeAll(where: {x==$0.id})
    }
    
    func moveUp(_ x: ItemIdentifier, keyPath: ListKeyPath) {
        if let idx = self[keyPath:keyPath].firstIndex(where: {x==$0.id}),
               idx != self[keyPath:keyPath].startIndex {
            self[keyPath:keyPath].swapAt(idx, idx - 1)
        }
    }
    
    func moveDown(_ x: ItemIdentifier, keyPath: ListKeyPath) {
        if let idx = self[keyPath:keyPath].firstIndex(where: {x==$0.id}),
               idx != self[keyPath:keyPath].endIndex - 1 {
            self[keyPath:keyPath].swapAt(idx, idx + 1)
        }
    }
    
    func add(_ x: String, keyPath: ListKeyPath) {
        self[keyPath:keyPath].append(Item(initialText: x))
    }
}

