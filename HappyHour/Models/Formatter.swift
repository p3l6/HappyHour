
import Foundation
import AppKit


extension ItemModel {
    func formatted() -> AttributedString {
        let settings = UserSettings()
        
        func addAllLinks(text: String) -> AttributedString {
            var mdText = text.replacingOccurrences(
                of: #"PR ?(\d+)"#,
                with: #"[$0]\(\#(settings.pullRequestURLprefix)$1\)"#,
                options: .regularExpression
            )
            
            for jiraPrefix in settings.jiraProjectprefixes.split(separator: " ") {
                mdText = mdText.replacingOccurrences(
                    of: #"(\#(jiraPrefix)-\d+)"#,
                    with: #"[$0]\(\#(settings.jiraURLprefix)$1\)"#,
                    options: .regularExpression
                )
            }
            
            do { return try AttributedString(markdown: mdText) }
            catch {
                print("Error in link formatting: \(mdText)")
                return AttributedString(text)
            }
        }
        
        func bold(_ string: String) -> AttributedString {
            var attrString =  AttributedString(string)
            attrString.inlinePresentationIntent = .stronglyEmphasized
            return attrString
        }
        
        var string = AttributedString("")
        
        var previousItem = false
        func printList(title: String, list: List, prefix: String) {
            if !list.items.isEmpty {
                if previousItem {
                    string.append(AttributedString("\n"))
                }
                previousItem = true
                string.append(bold(title))
                string.append(AttributedString(":\n"))
                for item in list.items {
                    string.append(AttributedString(prefix))
                    string.append(addAllLinks(text:item.text))
                    string.append(AttributedString("\n"))
                }
            } else if settings.formatEmptySections {
                if previousItem {
                    string.append(AttributedString("\n"))
                }
                previousItem = true
                string.append(bold(title))
                string.append(AttributedString(":\n(none)\n"))
            }
        }
        printList(title: settings.displayNameToday, list: today, prefix: "✅ ")
        printList(title: settings.displayNameTomorrow, list: tomorrow, prefix: "➡️ ")
        printList(title: settings.displayNameQBI, list: qbi, prefix: "⁉️ ")
        
        if !settings.footerItems.isEmpty {
            string.append(AttributedString("\n"))
            for item in settings.footerItems {
                string.append(bold("\(item) "))
                switch (footer[item] ?? .no) {
                case .yes: string.append(AttributedString("✅"))
                case .maybe: string.append(AttributedString("🤷"))
                case .no: string.append(AttributedString("❌"))
                }
                string.append(AttributedString("\n"))
            }
        }
        
        return string
    }
}
