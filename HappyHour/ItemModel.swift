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
    typealias List = [Item]
    typealias ListKeyPath = ReferenceWritableKeyPath<ItemModel,List>
    
    struct DiskData: Codable {
        let planned: [String]?
        let today: [String]?
        let tomorrow: [String]?
        let qbi: [String]?
        init(planned: [String]? = nil,
             today: [String]? = nil,
             tomorrow: [String]? = nil,
             qbi: [String]? = nil) {
            self.planned = planned
            self.today = today
            self.tomorrow = tomorrow
            self.qbi = qbi
        }
    }
    
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
        var diskData = DiskData()
        if FileManager.default.fileExists(atPath:file.path) {
            let dec = JSONDecoder.init()
            do {
                let data = FileManager.default.contents(atPath: file.path)
                diskData = try dec.decode(DiskData.self, from: data!)
            } catch {
                print("error trying load json file")
            }
        }
        
        planned = diskData.planned?.map { Item(initialText: $0) } ?? []
        today = diskData.today?.map { Item(initialText: $0) } ?? []
        tomorrow = diskData.tomorrow?.map { Item(initialText: $0) } ?? []
        qbi = diskData.qbi?.map { Item(initialText: $0) } ?? []
    }
    
    func save() {
        let data = DiskData(
            planned: planned.map { $0.text },
            today: today.map { $0.text },
            tomorrow: tomorrow.map { $0.text },
            qbi: qbi.map { $0.text }
        )
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
        //! there may be a more efficient way and a filter
        self[keyPath:keyPath].removeAll(where: {x==$0.id})
    }
    
    func add(_ x: String, keyPath: ListKeyPath) {
        self[keyPath:keyPath].append(Item(initialText: x))
    }
}

