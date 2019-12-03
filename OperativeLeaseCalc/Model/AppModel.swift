//
//  AppModel.swift
//  OperativeLeaseCalc
//
//  Created by Lukas Jezny on 26/11/2019.
//  Copyright © 2019 Lukas Jezny. All rights reserved.
//

import UIKit
import SwiftUI
import CocoaLumberjack

class AppModel:NSObject, ObservableObject {
    static let shared = AppModel()
    
    override init() {
        super.init()
        if obdEnabled {
            let _ = OBD2Manager.shared
        }
    }
    
    @Published var leaseParams = PersistentStorageManager.shared.loadLeaseParams()
    @Published var history = PersistentStorageManager.shared.loadHistory()
    @Published var lastOBD2State: Int?
    
    var lastOBD2StateFormatted: String {
        return lastOBD2State == nil ? "-- km" : "\(lastOBD2State!) km"
    }
    
    var realState: Int {
        return (self.history.first?.state as? Int) ?? 0
    }
    
    var realStateFormatted: String {
        return "\(realState) km"
    }
    
    var isOverlimit: Bool {
        return self.history.first?.isOverlimit(leaseParams: leaseParams) ?? false
    }
    
    var notifications: Bool {
        get{
            return leaseParams.notifications
        }
        set(v) {
            leaseParams.notifications = v
            if v {
                NotificationManager.shared.requestPermission {[weak self] (b) in
                    if !b {
                        self?.notifications = false
                    }
                    PersistentStorageManager.shared.saveContext()
                }
            }
        }
    }
    
    var obdEnabled: Bool {
        get{
            return leaseParams.obdEnabled
        }
        set(v) {
            leaseParams.obdEnabled = v
            if v {
                let _ = OBD2Manager.shared
            }
            PersistentStorageManager.shared.saveContext()
        }
    }
    
    func addState(date:Date, state: Int) {
        self.history.insert(PersistentStorageManager.shared.addHistory(date: date, state: state), at: 0)
        PersistentStorageManager.shared.saveContext()
    }
    func addState(state: Int) {
        addState(date: Date(), state: state)
    }
    
    func addStateFromOBD2(state: Int) {
        DDLogInfo("AppModel: addStateFromOBD2 state: \(state)" )
        
        if lastOBD2State == state {
            return
        }
        lastOBD2State = state
        
        if obdEnabled {
            let totalState = state + Int(truncating: (leaseParams.obdOffset ?? 0))
            self.addState(state: totalState)
            DDLogInfo("AppModel: addStateFromOBD2 obd enabled, saving to history" )
            if notifications {
                DDLogInfo("AppModel: addStateFromOBD2 notification enabled, requesting notification")
                NotificationManager.shared.notify(idealState: leaseParams.idealState ?? 0, actualState:  totalState)
            }
        }
    }
}
