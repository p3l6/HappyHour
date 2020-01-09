//
//  ItemModel.swift
//  HappyHour
//
//  Created by Paul Landers on 1/9/20.
//  Copyright © 2020 Paul Landers. All rights reserved.
//

import Foundation

final class ItemModel: ObservableObject {
    static var permanumber = 4
    
    struct Item {
        let id: Int
        let text: String
    }

    @Published var items = [Item(id: 0, text: "A"),Item(id: 1, text: "B"),Item(id: 3, text: "C")]
    
    func remove(_ x: Int) {
        //! there may be a more efficient way and a filter
        items.removeAll(where: {x==$0.id})
    }
    
    func add(_ x: String) {
        items.append(Item(id: ItemModel.permanumber, text: x))
        ItemModel.permanumber += 1
    }
    
    func update(_ x: Int, to: String) {
        let index = items.firstIndex(where: {x==$0.id})!
        items[index] = Item(id: items[index].id, text: to)
    }
}

