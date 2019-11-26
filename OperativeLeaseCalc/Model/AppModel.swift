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
    var history = PersistentStorageManager.shared.loadHistory()
    
    func addState(state: Int) {
        self.history.insert(PersistentStorageManager.shared.addHistory(state: state), at: 0)
    }
}
