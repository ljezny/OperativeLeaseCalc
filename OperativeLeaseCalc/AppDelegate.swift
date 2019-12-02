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
import CocoaLumberjack

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let appRater = AppReviewer()
    
    var fileLoger: DDFileLogger?
    
    var logFileDataArray: [NSData] {
        get {
            let logFilePaths = fileLoger!.logFileManager.sortedLogFilePaths
            var logFileDataArray = [NSData]()
            for logFilePath in logFilePaths ?? [] {
                let fileURL = NSURL(fileURLWithPath: logFilePath)
                if let logFileData = try? NSData(contentsOf: fileURL as URL, options: NSData.ReadingOptions.mappedIfSafe) {
                    // Insert at front to reverse the order, so that oldest logs appear first.
                    logFileDataArray.insert(logFileData, at: 0)
                }
            }
            return logFileDataArray
        }
    }

    private func initLogger() -> DDFileLogger {
        DDLog.add(DDTTYLogger.sharedInstance) // TTY = Xcode console
         
        let logger: DDFileLogger = DDFileLogger() // File Logger
        logger.rollingFrequency = TimeInterval(60*60*24)  // 24 hours
        logger.logFileManager.maximumNumberOfLogFiles = 3
        DDLog.add(logger)
        
        return logger
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.fileLoger = self.initLogger()
        
        #if DEBUG
        if AppModel.shared.history.count == 0 {
            var sum = 0;
            let days = 40
            for i in 1...days {
                let calendar = Calendar.current
                let d = calendar.date(byAdding: .day, value: -days+i, to: Date())!
                sum += Int(sqrt(Double(arc4random() % 60*60)))
                AppModel.shared.addState(date: d, state: sum)
            }
            AppModel.shared.leaseParams.leaseStart = Calendar.current.date(byAdding: .day, value: -days, to: Date())!
            AppModel.shared.leaseParams.yearLimit = 10000
            PersistentStorageManager.shared.saveContext()
        }
        #endif
        
        
        MSAppCenter.start("6bf308eb-2b84-40bd-b6b0-432d1032595d", withServices:[
          MSAnalytics.self,
          MSCrashes.self
        ])
        
        appRater.checkReview()
        
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

