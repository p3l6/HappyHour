
import Foundation
import AppKit

extension ItemModel {
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
                    let path = "\(pullUrl)\(text[Range(match.range(at: 1), in: text)!])"
                    guard let url = URL(string:path) else { return }
                    attrText.addAttributes([NSAttributedString.Key.link: url], range: match.range)
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
            if !list.items.isEmpty {
                string.append(bold(title))
                string.append(attr(":\n"))
                for item in list.items {
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
}
