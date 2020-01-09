//
//  ItemModel.swift
//  HappyHour
//
//  Created by Paul Landers on 1/9/20.
//  Copyright © 2020 Paul Landers. All rights reserved.
//

import Foundation

final class ItemModel: ObservableObject {
     @Published var items = ["A","B","C"]
    
    func remove(_ x: String) {
        //! remove specific item, not all matching ones
        items.removeAll(where: {$0==x})
    }
    
    func add(_ x: String) {
        items.append(x)
    }
}

