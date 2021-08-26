
import Foundation
import AppKit

fileprivate func makeLinks(_ text: NSMutableAttributedString,
                           base: String,
                           matching regex: NSRegularExpression,
                           prefix: String) {
    guard prefix.count > 0 else { return }
    
    let fullRange = NSRange(location:0, length:base.utf16.count)
    
    regex.enumerateMatches(in: base, options: [], range: fullRange) { (match, _, _) in
        guard let match = match else { return }
        let path = "\(prefix)\(text.attributedSubstring(from: match.range(at: 1)).string)"
        guard let url = URL(string:path) else { return }
        text.addAttributes([NSAttributedString.Key.link: url], range: match.range)
    }
}

extension ItemModel {
    func formatted() -> NSAttributedString {
        // MARKDOWN Version of pr replacement
        // string = string.replacingOccurrences(
        //     of: #"PR ?(\d+)"#,
        //     with: #"[PR]\(\#(pullUrl)$1\)"#,
        //     options: .regularExpression
        // )
        let settings = UserSettings()
        let baseAttrs = [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 14.0)]
        let boldAttrs = [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 14.0, weight: .bold)]
        
        func addAllLinks(text: String) -> NSAttributedString {
            let attrText = NSMutableAttributedString(string: text, attributes: baseAttrs)
            
            if let regex = try? NSRegularExpression(pattern: #"PR ?(\d+)"#) {
                makeLinks(attrText, base: text, matching: regex, prefix: settings.pullRequestURLprefix)
            }
            
            for prefix in settings.jiraProjectprefixes.split(separator: " ") {
                if let regex = try? NSRegularExpression(pattern: #"(\#(prefix)-\d+)"#) {
                    makeLinks(attrText, base: text, matching: regex, prefix: settings.jiraURLprefix)
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
        
        var previousItem = false
        func printList(title: String, list: List, prefix: String) {
            if !list.items.isEmpty {
                if previousItem {
                    string.append(attr("\n"))
                }
                previousItem = true
                string.append(bold(title))
                string.append(attr(":\n"))
                for item in list.items {
                    string.append(attr(prefix))
                    string.append(addAllLinks(text:item.text))
                    string.append(attr("\n"))
                }
            } else if settings.formatEmptySections {
                if previousItem {
                    string.append(attr("\n"))
                }
                previousItem = true
                string.append(bold(title))
                string.append(attr(":\n(none)"))
            }
        }
        printList(title: settings.displayNameToday, list: today, prefix: "✅ ")
        printList(title: settings.displayNameTomorrow, list: tomorrow, prefix: "➡️ ")
        printList(title: settings.displayNameQBI, list: qbi, prefix: "⁉️ ")
        
        if !settings.footerItems.isEmpty {
            string.append(attr("\n"))
            for item in settings.footerItems {
                string.append(bold("\(item) "))
                switch (footer[item] ?? .no) {
                case .yes: string.append(attr("✅"))
                case .maybe: string.append(attr("🤷"))
                case .no: string.append(attr("❌"))
                }
                string.append(attr("\n"))
            }
        }
        
        return string
    }
}
