
import SwiftUI

@main
struct HappyHourApp: App {
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
        }
        
        Settings {
            SettingsView()
                .environmentObject(settings)
        }
    }
}

// TODO: There's a menu option to create a new window? Should disable that somehow. Single window app. Related to LSGUI im sure

//        var statusBarItem: NSStatusItem!
//        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
//        statusBarItem.button?.title = "🍺"
//        statusBarItem.button?.action = #selector(AppDelegate.showWindow)
