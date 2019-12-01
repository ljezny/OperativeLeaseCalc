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
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("notification.title", comment: "")
        content.body = String.init(format: NSLocalizedString("notification.body", comment: ""), actualState,idealState)
        content.sound = UNNotificationSound.default
        
        UNUserNotificationCenter.current().add(UNNotificationRequest.init(identifier: "OperativeLease", content:content, trigger: nil)) { (error) in
            
        }
    }
}
