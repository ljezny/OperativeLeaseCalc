//
//  LocationManager.swift
//  OperativeLeaseCalc
//
//  Created by Lukas Jezny on 29/12/2019.
//  Copyright © 2019 Lukas Jezny. All rights reserved.
//

import UIKit
import CoreLocation
import CocoaLumberjack

class LocationManager:NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    private let manager = CLLocationManager()
    
    override init() {
        super.init()
        manager.delegate = self
    }
    
    func start() {
        DDLogInfo("LocationManager: start")
        manager.startMonitoringSignificantLocationChanges()
    }
    
    func stop() {
        DDLogInfo("LocationManager: stop")
        manager.stopMonitoringSignificantLocationChanges()
    }
    
    func requestAuthorization() {
        manager.requestAlwaysAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        DDLogInfo("LocationManager: didUpdateLocations: \(locations)")
        OBD2Manager.shared.requestDistance()
    }
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        DDLogInfo("LocationManager: locationManagerDidPauseLocationUpdates")
    }
    
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        DDLogInfo("LocationManager: locationManagerDidResumeLocationUpdates")
    }
}
