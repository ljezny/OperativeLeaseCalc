//
//  NotificationManager.swift
//  OperativeLeaseCalc
//
//  Created by Lukas Jezny on 24/11/2019.
//  Copyright © 2019 Lukas Jezny. All rights reserved.
//

import UIKit

class NotificationManager {
    static let shared = NotificationManager()
    
    func requestPermission(completion: @escaping (Bool) -> ()) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound]) { (b,error ) in
            completion(b)
        }
    }
    
    func notify(idealState: Int, actualState: Int) {
        notify(title: NSLocalizedString("notification.title", comment: ""), body: String.init(format: NSLocalizedString("notification.body", comment: ""), actualState,idealState))
    }
    
    func notify(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        UNUserNotificationCenter.current().add(UNNotificationRequest.init(identifier: "OperativeLease", content:content, trigger: nil)) { (error) in
            
        }
    }
}
