
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
