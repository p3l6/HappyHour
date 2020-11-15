
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
    
    init() {
        planned = []
        today = []
        tomorrow = []
        qbi = []
    }
    
    func save() {
        //TODO: we can probably refactor this method away
        DiskData(itemModel:self).save()
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

