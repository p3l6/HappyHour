//
//  ItemModel.swift
//  HappyHour
//
//  Created by Paul Landers on 1/9/20.
//  Copyright © 2020 Paul Landers. All rights reserved.
//

import Foundation

final class ItemModel: ObservableObject {
    
    typealias ItemIdentifier = Int
    
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

    @Published var items = [Item(initialText: "A"),Item(initialText: "B"),Item(initialText: "C")]
    
    var itemIds: [ItemIdentifier] { items.map{$0.id} }
    
    func item(_ x: ItemIdentifier) -> Item {
        let index = items.firstIndex(where: {x==$0.id})!
        return items[index]
    }
    
    func remove(_ x: ItemIdentifier) {
        //! there may be a more efficient way and a filter
        items.removeAll(where: {x==$0.id})
    }
    
    func add(_ x: String) {
        items.append(Item(initialText: x))
    }
}

