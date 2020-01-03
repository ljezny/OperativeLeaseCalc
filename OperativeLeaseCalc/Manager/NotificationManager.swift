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
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { (b,error ) in
            completion(b)
        }
    }
    
    func notifyState(idealState: Int, actualState: Int) {
        notify(title: NSLocalizedString("notification.title", comment: ""), body: String.init(format: NSLocalizedString("notification.state.body", comment: ""), actualState,idealState), id: "State")
    }
    
    func notifyConnection() {
        notify(title: NSLocalizedString("notification.title", comment: ""), body:  NSLocalizedString("notification.connect.body", comment: ""), id: "ConnectionState")
    }
    
    func notifyDisconnection() {
        notify(title: NSLocalizedString("notification.title", comment: ""), body:  NSLocalizedString("notification.disconnect.body", comment: ""), id: "ConnectionState")
    }
    
    func notify(title: String, body: String, id: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        UNUserNotificationCenter.current().add(UNNotificationRequest.init(identifier: id, content:content, trigger: nil)) { (error) in
            
        }
    }
}
