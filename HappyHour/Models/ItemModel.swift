
import Foundation
import AppKit

final class ItemModel: ObservableObject {
    final class Item: ObservableObject, Identifiable {
        let id = UUID()
        @Published var text: String
        
        init(initialText: String) {
            text = initialText
        }
    }
    
    final class List: ObservableObject {
        @Published var items: [Item] = []
        
        func remove(at index: Int) {
            self.items.remove(at: index)
            // TODO: Should save here?
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
        let settings = UserSettings()
        
        // here, keep and toPlanned have the same meaning
        if settings.resetBehaviorPlanned == .discard { planned.items.removeAll() }
        
        // add anything else to planned
        if settings.resetBehaviorToday    == .toPlanned { planned.items.append(contentsOf: today.items) }
        if settings.resetBehaviorTomorrow == .toPlanned { planned.items.append(contentsOf: tomorrow.items) }
        if settings.resetBehaviorQbi      == .toPlanned { planned.items.append(contentsOf: qbi.items) }

        // clear what's needed
        if settings.resetBehaviorToday    != .keep { today.items.removeAll() }
        if settings.resetBehaviorTomorrow != .keep { tomorrow.items.removeAll() }
        if settings.resetBehaviorQbi      != .keep { qbi.items.removeAll() }
        
        self.save()
    }
}
