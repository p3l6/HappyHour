//
//  AppDelegate.swift
//  HappyHour
//
//  Created by Paul Landers on 1/8/20.
//  Copyright © 2020 Paul Landers. All rights reserved.
//

import SwiftUI
import UserNotifications

@main
struct HappyHourApp: App {
    let settings = UserSettings()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(ItemModel(filename: "Standup"))
                .environmentObject(TaskTimer())
                .environmentObject(settings)
            // TODO: Do these modifiers mean anything?
    //        window.setFrameAutosaveName("Main Window")
    //        window.contentView = NSHostingView(rootView: contentView)
    //        window.isReleasedWhenClosed = false
    //        window.makeKeyAndOrderFront(nil)
    //        .defaultAppStorage(T##store: UserDefaults##UserDefaults)
        }
        
        Settings {
            SettingsView()
                .environmentObject(settings)
        }
//        WKNotificationScene {
//            let notificationCenter = UNUserNotificationCenter.current()
//        let options: UNAuthorizationOptions = [.alert, .sound]
//        notificationCenter.requestAuthorization(options: options) {
//            (didAllow, error) in
//            if !didAllow {
//                print("User has declined notifications")
//            }
//        }
//        notificationCenter.delegate = self

//    @objc func showWindow() {
//        window.makeKeyAndOrderFront(nil)
//        NSApp.activate(ignoringOtherApps: true)
//    }
//


//extension AppDelegate: UNUserNotificationCenterDelegate {
//    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//        self.showWindow()
//        completionHandler()
//    }
//
//    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        completionHandler([.alert, .sound])
//    }
            //}
//        }
    }
}

//        var statusBarItem: NSStatusItem!
//        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
//        statusBarItem.button?.title = "🍺"
//        statusBarItem.button?.action = #selector(AppDelegate.showWindow)
