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

    @Published var items: [Item]
    let file: URL
    
    static func dataDirectory() -> URL {
        var dir: URL?
        do {
            dir = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            dir = dir?.appendingPathComponent("dev.pwxn.HappyHour")
        }
        catch {
            // TODO what to do here? quit with a message?
        }
        return dir!
    }
    
    init() {
        let dir = ItemModel.dataDirectory()
        file = dir.appendingPathComponent("data.json")
        var strings = [String]()
        if FileManager.default.fileExists(atPath:file.path) {
            let dec = JSONDecoder.init()
            do {
                let data = FileManager.default.contents(atPath: file.path)
                strings = try dec.decode([String].self, from: data!)
            } catch {
                print("error trying load json file")
            }
        }
        
        items = strings.map { Item(initialText: $0) }
    }
    
    func save() {
        let data = items.map { $0.text }
        let enc = JSONEncoder.init()
        do {
            let encoded = try enc.encode(data)
            try FileManager.default.createDirectory(at: ItemModel.dataDirectory(), withIntermediateDirectories: true)
            try encoded.write(to: file)
        }
        catch let e {
            print("Error writing to file: \(e.localizedDescription)")
        }
    }
    
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

