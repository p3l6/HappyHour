
import Foundation

struct DiskData: Codable {
    let planned: [String]?
    let today: [String]?
    let tomorrow: [String]?
    let qbi: [String]?
    let footer: [String: String]?
    
    init(planned: [String]? = nil,
         today: [String]? = nil,
         tomorrow: [String]? = nil,
         qbi: [String]? = nil) {
        self.planned = planned
        self.today = today
        self.tomorrow = tomorrow
        self.qbi = qbi
        self.footer = [:]
    }
    
    init(itemModel: ItemModel) {
        planned = itemModel.planned.items.map { $0.text }
        today = itemModel.today.items.map { $0.text }
        tomorrow = itemModel.tomorrow.items.map { $0.text }
        qbi = itemModel.qbi.items.map { $0.text }
        footer = itemModel.footer.mapValues { $0.rawValue }
    }
    
    func makeModel() -> ItemModel {
        let itemModel = ItemModel()
        
        self.planned?.forEach { itemModel.planned.add($0) }
        self.today?.forEach { itemModel.today.add($0) }
        self.tomorrow?.forEach { itemModel.tomorrow.add($0) }
        self.qbi?.forEach { itemModel.qbi.add($0) }
        self.footer?.forEach {
            if let value = ItemModel.FooterStatus(rawValue: $0.value) {
                itemModel.footer[$0.key] = value
            }
        }
        return itemModel
    }
    
    static func dataDirectory() -> URL? {
        var dir: URL?
        do {
            dir = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            dir = dir?.appendingPathComponent("dev.pwxn.HappyHour")
        }
        catch {
            return nil
        }
        return dir
    }
    
    static func load() -> DiskData {
        guard let dir = DiskData.dataDirectory() else {
            print("Error: Could not determine application storage directory.")
            return DiskData()
        }
        
        let name = UserSettings().storageFileName
        let file = dir.appendingPathComponent(name).appendingPathExtension("json")

        var diskData = DiskData()
        if FileManager.default.fileExists(atPath:file.path) {
            do {
                let data = FileManager.default.contents(atPath: file.path)
                diskData = try JSONDecoder.init().decode(DiskData.self, from: data!)
            } catch {
                print("Error: Could not load json file into model")
            }
        }
        return diskData
    }
    
    func save() async {
        guard let dir = DiskData.dataDirectory() else { return }
        let name = UserSettings().storageFileName
        let file = dir.appendingPathComponent(name).appendingPathExtension("json")

        do {
            let encoded = try JSONEncoder.init().encode(self)
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            try encoded.write(to: file)
        }
        catch let e {
            print("Error: Could not write to file \(file): \(e.localizedDescription)")
        }
    }
}
