
import Foundation
import AppKit

final class ItemModel: ObservableObject {
    typealias ItemIdentifier = Int
    
    final class Item: ObservableObject, Identifiable {
        static var permanumber = 0
        
        let id: ItemIdentifier
        @Published var text: String
        
        init(initialText: String) {
            id = Item.permanumber
            Item.permanumber += 1
            text = initialText
        }
    }
    
    final class List: ObservableObject {
        @Published var items: [Item] = []
        
        func remove(_ x: ItemIdentifier) {
            //TODO: there may be a more efficient way and a filter
            self.items.removeAll(where: {x==$0.id})
        }
        
        func moveUp(_ x: ItemIdentifier) {
            if let idx = self.items.firstIndex(where: {x==$0.id}),
               idx != self.items.startIndex {
                self.items.swapAt(idx, idx - 1)
            }
            // TODO: Should save here?
        }
        
        func moveDown(_ x: ItemIdentifier) {
            if let idx = self.items.firstIndex(where: {x==$0.id}),
               idx != self.items.endIndex - 1 {
                self.items.swapAt(idx, idx + 1)
            }
        }
        
        func add(_ x: String) {
            self.items.append(Item(initialText: x))
        }
    }

    @Published var planned: List
    @Published var today: List
    @Published var tomorrow: List
    @Published var qbi: List
    
    init() {
        planned = List()
        today = List()
        tomorrow = List()
        qbi = List()
    }
    
    func save() {
        //TODO: we can probably refactor this method away
        DiskData(itemModel:self).save()
    }
    
    func clear() {
        planned = tomorrow
        today = List()
        tomorrow = List()
        qbi = List()
        self.save()
    }
}
