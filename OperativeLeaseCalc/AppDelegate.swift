//
//  AppDelegate.swift
//  OperativeLeaseCalc
//
//  Created by Lukas Jezny on 23/11/2019.
//  Copyright © 2019 Lukas Jezny. All rights reserved.
//

import UIKit
import AppCenter
import AppCenterAnalytics
import AppCenterCrashes

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        #if DEBUG
        if AppModel.shared.history.count == 0 {
            var sum = 0;
            for i in 1...30 {
                let calendar = Calendar.current
                let d = calendar.date(byAdding: .day, value: 30+i, to: Date())!
                sum += Int(arc4random() % 30)
                AppModel.shared.addState(date: d, state: sum)
            }
            
            PersistentStorageManager.shared.saveContext()
        }
        #endif
        
        
        MSAppCenter.start("6bf308eb-2b84-40bd-b6b0-432d1032595d", withServices:[
          MSAnalytics.self,
          MSCrashes.self
        ])
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    func applicationWillResignActive(_ application: UIApplication) {
        PersistentStorageManager.shared.saveContext()
    }
    func applicationWillTerminate(_ application: UIApplication) {
        PersistentStorageManager.shared.saveContext()
    }

}

