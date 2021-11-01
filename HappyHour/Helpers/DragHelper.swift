
import Foundation
import UniformTypeIdentifiers

/**
 This file exists to help reimplement some included features of swiftUI's List
 However, List has some drawbacks, including:
 * TextField tab loops dont work
 * Conflicts on selecting vs editing TextFields
 * Styles are restricted to the included system styles
 This class seeks to work around this by enabling drag & drop reordering on Non-List groups,
 Since that is the main feature I wanted to get out of List
 */

class DragHelper: NSObject, NSItemProviderWriting, NSItemProviderReading, Codable {
    static let type = [UTType.data.identifier]
    static let readableTypeIdentifiersForItemProvider = type
    static let writableTypeIdentifiersForItemProvider = type
    
    let source: UUID
    
    required init(_ source: UUID) {
        self.source = source
    }
    
    static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> Self {
        do {
            return try JSONDecoder().decode(Self.self, from: data)
        } catch {
            fatalError("Error: decoding dragged object")
        }
    }
    
    func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
        do {
            completionHandler(try JSONEncoder().encode(self), nil)
        } catch {
            completionHandler(nil, error)
        }
        return nil
    }
}

func dropHelper(_ itemProviders: [NSItemProvider], _ wrapping: @escaping (DragHelper) -> Void) -> Bool {
    guard let itemProvider = itemProviders.first else { return false }
    
    itemProvider.loadObject(ofClass: DragHelper.self) { maybeDragHelper, foo in
        guard let dragHelper = maybeDragHelper as? DragHelper else { return }
        DispatchQueue.main.async {
            wrapping(dragHelper)
        }
    }
    return true
}
