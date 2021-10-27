
import Foundation
import AppKit

final class ItemModel: ObservableObject {
    final class Item: ObservableObject, Identifiable {
        @Published var text: String { didSet { dirty = true }}
        let id = UUID()
        fileprivate var dirty = true
        
        init(initialText: String) {
            text = initialText
        }
    }
    
    final class List: ObservableObject {
        @Published var items: [Item] = []
        fileprivate var dirty = false
        
        func remove(at index: Int) {
            items.remove(at: index)
            dirty = true
        }
        
        func add(_ x: String) {
            items.append(Item(initialText: x))
        }
    }
    
    enum FooterStatus: String {
        case yes = "yes"
        case maybe = "maybe"
        case no = "no"
    }

    @Published var planned: List
    @Published var today: List
    @Published var tomorrow: List
    @Published var qbi: List
    @Published var footer: [String: FooterStatus]
    
    init() {
        planned = List()
        today = List()
        tomorrow = List()
        qbi = List()
        footer = [:]
    }
    
    func save() {
        let lists = [planned, today, tomorrow, qbi]
        let dirtyItems = lists.flatMap { $0.items.filter(\.dirty) }
        let dirtyLists = lists.filter(\.dirty)
        
        print("checking for save...")
        if dirtyItems.count != 0 ||
           dirtyLists.count != 0 {
            print("  saving")
            
            dirtyItems.forEach { $0.dirty = false }
            dirtyLists.forEach { $0.dirty = false }
            
            Task.init(priority: .background) {
                await DiskData(itemModel:self).save()
            }
        }
    }
    
    func remove(id: UUID) {
        //TODO: could be more efficient?
        planned.items.removeAll(where: {item in item.id == id })
        today.items.removeAll(where: {item in item.id == id })
        tomorrow.items.removeAll(where: {item in item.id == id })
        qbi.items.removeAll(where: {item in item.id == id })
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
    }
}
