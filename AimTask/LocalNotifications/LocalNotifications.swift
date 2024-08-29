//
//  LocalNotifications.swift
//  AimTask
//
//  Created by Vilayath Mohammed on 29/8/2024.
//

import Foundation
import SwiftUI
import UserNotifications

final class LocalNotifications: NSObject, UNUserNotificationCenterDelegate {
    
    // Singleton pattern
    static let shared = LocalNotifications()

    private override init() {
        super.init()
        self.requestNotificationPermission()
        UNUserNotificationCenter.current().delegate = self
    }
    
    // Request notification permission from the user
    func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Permission Granted!")
            } else if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    
    // Schedule the notification
    func scheduleNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to add notification: \(error.localizedDescription)")
            }
        }
    }
    
    // Handle the notification when the app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }

    // Handle the user's response to the notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
         
            completionHandler()
        }
}
