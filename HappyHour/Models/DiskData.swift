
import Foundation

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
    
    init(itemModel: ItemModel) {
        planned = itemModel.planned.map { $0.text }
        today = itemModel.today.map { $0.text }
        tomorrow = itemModel.tomorrow.map { $0.text }
        qbi = itemModel.qbi.map { $0.text }
    }
    
    func makeModel() -> ItemModel {
        let itemModel = ItemModel()
        
        self.planned?.forEach { itemModel.add($0, keyPath: \.planned) }
        self.today?.forEach { itemModel.add($0, keyPath: \.today) }
        self.tomorrow?.forEach { itemModel.add($0, keyPath: \.tomorrow) }
        self.qbi?.forEach { itemModel.add($0, keyPath: \.qbi) }
        return itemModel
    }
    
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
    
    static func load() -> DiskData {
        let dir = DiskData.dataDirectory()
        let name = UserSettings().storageFileName
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
    
    func save() {
        let dir = DiskData.dataDirectory()
        let name = UserSettings().storageFileName
        let file = dir.appendingPathComponent(name).appendingPathExtension("json")

        let enc = JSONEncoder.init()
        do {
            let encoded = try enc.encode(self)
            try FileManager.default.createDirectory(at: DiskData.dataDirectory(), withIntermediateDirectories: true)
            try encoded.write(to: file)
        }
        catch let e {
            print("Error writing to file: \(e.localizedDescription)")
        }
    }
}
