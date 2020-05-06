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
    var duration = 0
    
    private func sendNote(message:String) {
        let content = UNMutableNotificationContent()
        content.title = "Task Timer"
        content.body = message
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: "TaskTimerMessage", content: content, trigger: nil)

        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
    }
    
    func start(minutes: Int) {
        status = .running
        duration = minutes
        let interval = 60.0 * Double(minutes)
        delayTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false, block: { timer in self.finish() })
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
            print("TaskTimer cancelled")
        } else {
            print("TaskTimer reset")
        }
        status = .idle
    }
}
