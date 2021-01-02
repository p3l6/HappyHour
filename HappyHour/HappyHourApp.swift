
import SwiftUI

@main
struct HappyHourApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let settings = UserSettings()
    let itemModel = DiskData.load().makeModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(itemModel)
                .environmentObject(TaskTimer())
                .environmentObject(settings)
                .onReceive(NotificationCenter.default.publisher(for: NSApplication.willResignActiveNotification)) { _ in
                    itemModel.save()
                }
                .handlesExternalEvents(preferring: Set(arrayLiteral: "showWindow"), allowing: Set(arrayLiteral: "*"))
        }.handlesExternalEvents(matching: Set(arrayLiteral: "showWindow"))
        
        Settings {
            SettingsView()
                .environmentObject(settings)
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBarItem: NSStatusItem? = nil
    @Environment(\.openURL) var openURL
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        let statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusBarItem.button?.action = #selector(AppDelegate.showWindow)
        statusBarItem.button?.target = self
        
        statusBarItem.button?.image = NSImage(named: NSImage.Name("StatusBarIcon"))
        statusBarItem.button?.image?.size = NSSize(width: 18.0, height: 18.0)
        statusBarItem.button?.image?.isTemplate = true

        // Store in property to retain object
        self.statusBarItem = statusBarItem
    }
    
    @objc func showWindow() {
        if let url = URL(string: "happyhour://showWindow") {
            openURL(url)
        }
    }
}
