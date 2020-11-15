
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
        }
        
        Settings {
            SettingsView()
                .environmentObject(settings)
        }
    }
}

//        var statusBarItem: NSStatusItem!
//        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
//        statusBarItem.button?.title = "🍺"
//        statusBarItem.button?.action = #selector(AppDelegate.showWindow)
