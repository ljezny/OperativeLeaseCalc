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
    
    var leaseParams = PersistentStorageManager.shared.loadLeaseParams()
    @Published var history = PersistentStorageManager.shared.loadHistory()
    
    var lastOBD2State: Int?
    
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
