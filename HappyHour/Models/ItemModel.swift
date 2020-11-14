//
//  ItemModel.swift
//  HappyHour
//
//  Created by Paul Landers on 1/9/20.
//  Copyright © 2020 Paul Landers. All rights reserved.
//

import Foundation
import AppKit

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
        
        static func load(name:String) -> DiskData {
            let dir = ItemModel.dataDirectory()
            let file = dir.appendingPathComponent(name).appendingPathExtension("json")

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
            return diskData
        }
        
        func save(name: String) {
            let dir = ItemModel.dataDirectory()
            let file = dir.appendingPathComponent(name).appendingPathExtension("json")

            let enc = JSONEncoder.init()
            do {
                let encoded = try enc.encode(self)
                try FileManager.default.createDirectory(at: ItemModel.dataDirectory(), withIntermediateDirectories: true)
                try encoded.write(to: file)
            }
            catch let e {
                print("Error writing to file: \(e.localizedDescription)")
            }
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
    
    func formatted() -> NSAttributedString {
        // MARKDOWN Version of pr replacement
        // string = string.replacingOccurrences(
        //     of: #"PR ?(\d+)"#,
        //     with: #"[PR]\(\#(pullUrl)$1\)"#,
        //     options: .regularExpression
        // )
        let baseAttrs = [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 14.0)]
        let boldAttrs = [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 14.0, weight: .bold)]
        
        func transform(text: String) -> NSAttributedString {
            let attrText = NSMutableAttributedString(string: text, attributes: baseAttrs)
            let pullUrl = UserSettings().pullRequestURLprefix
            if pullUrl.count > 0 {
                let fullRange = NSRange(text.startIndex..<text.endIndex, in: text)
                let regex = try! NSRegularExpression(pattern: #"PR ?(\d+)"#)
                regex.enumerateMatches(in: text, options: [], range: fullRange) { (match, _, _) in
                    guard let match = match else { return }
                    // TODO: can crash, for example if pullUrl is set to garbage
                    let path = "\(pullUrl)\(text[Range(match.range(at: 1), in: text)!])"
                    attrText.addAttributes([NSAttributedString.Key.link: URL(string:path)!], range: match.range)
                }
            }
            return attrText
        }
        
        func attr(_ string: String) -> NSAttributedString {
            return NSMutableAttributedString(string: string, attributes: baseAttrs)
        }
        
        func bold(_ string: String) -> NSAttributedString {
            return NSMutableAttributedString(string: string, attributes:boldAttrs)
        }
        
        let string = NSMutableAttributedString(string: "", attributes: baseAttrs)
        
        func printList(title: String, list: List, prefix: String) {
            if !list.isEmpty {
                string.append(bold(title))
                string.append(attr(":\n"))
                for item in list {
                    string.append(attr(prefix))
                    string.append(transform(text:item.text))
                    string.append(attr("\n"))
                }
            }
        }
        printList(title: "Today", list: today, prefix: "✅ ")
        printList(title: "Tomorrow", list: tomorrow, prefix: "➡️ ")
        printList(title: "QBI", list: qbi, prefix: "⁉️ ")
        
        return string
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

