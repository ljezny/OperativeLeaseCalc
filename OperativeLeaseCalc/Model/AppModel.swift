//
//  AppModel.swift
//  OperativeLeaseCalc
//
//  Created by Lukas Jezny on 26/11/2019.
//  Copyright © 2019 Lukas Jezny. All rights reserved.
//

import UIKit

class AppModel:NSObject, ObservableObject {
    static let shared = AppModel()
    
    override init() {
        super.init()
        if obdEnabled {
            let _ = OBD2Manager.shared
        }
    }
    
    var leaseParams = PersistentStorageManager.shared.loadLeaseParams()
    @Published var history = PersistentStorageManager.shared.loadHistory()
    
    var lastOBD2State: Int?
    
    var realState: Int {
        return (self.history.first?.state as? Int) ?? 0
    }
    
    var realStateFormatted: String {
        return "\(realState) km"
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
        }
    }
    
    func addState(date:Date, state: Int) {
        self.history.insert(PersistentStorageManager.shared.addHistory(date: date, state: state), at: 0)
    }
    func addState(state: Int) {
        addState(date: Date(), state: state)
    }
    
    func addStateFromOBD2(state: Int) {
        lastOBD2State = state
        self.addState(state: state)
    }
}
