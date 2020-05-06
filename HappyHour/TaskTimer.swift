//
//  TaskTimer.swift
//  HappyHour
//
//  Created by Paul Landers on 5/6/20.
//  Copyright © 2020 Paul Landers. All rights reserved.
//

import Foundation
import UserNotifications

final class TaskTimer: ObservableObject {
    enum Status {
        case idle
        case running
        case finished
    }
    
    @Published var status = Status.idle
    var delayTimer: Timer?
    
    var statusLabel: String {
        switch status {
        case .idle: return "Start 5 sec"
        case .running: return "Work Time!"
        case .finished: return "Timer finished. (reset)"
        }
    }
    
    private func sendNote(message:String) {
        let noteCenter = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = "Task Timer"
        content.body = message
        content.sound = UNNotificationSound.default
        
        let identifier = "Local Notification"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)

        noteCenter.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
    }
    
    func start() {
        status = .running
        delayTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: { timer in self.finish() })
        print("TaskTimer started")
    }
    
    private func finish() {
        sendNote(message: "Task timer has finished!")
        delayTimer = nil
        status = .finished
        print("TaskTimer finished. Notification sent")
    }
    
    func reset() {
        if let t = delayTimer {
            t.invalidate()
            delayTimer = nil
        }
        status = .idle
        print("TaskTimer reset or cancelled")
    }
}
