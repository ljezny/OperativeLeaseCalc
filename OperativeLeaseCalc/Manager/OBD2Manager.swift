//
//  OBDManager.swift
//  OperativeLeaseCalc
//
//  Created by Lukas Jezny on 28/11/2019.
//  Copyright © 2019 Lukas Jezny. All rights reserved.
//

import UIKit
import CoreBluetooth

class OBD2Device: NSObject, CBPeripheralDelegate {
    let peripheral: CBPeripheral
    
    static let SERVICE_UUID = CBUUID.init(string: "0xFFF0")
    static let TX_CHAR_UUID = CBUUID.init(string: "0xFFF2")
    static let RX_CHAR_UUID = CBUUID.init(string: "0xFFF1")
    
    var txCharacteristics: CBCharacteristic?
    var rxCharacteristics: CBCharacteristic?
    
    init(peripheral: CBPeripheral) {
        self.peripheral = peripheral
        super.init()
        self.peripheral.delegate = self
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        self.peripheral.services?.forEach({ (service) in
            if service.uuid == OBD2Device.SERVICE_UUID {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        })
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        service.characteristics?.forEach({ (c) in
            if c.uuid == OBD2Device.TX_CHAR_UUID {
                txCharacteristics = c
                requestDistance()
            }
            if c.uuid == OBD2Device.RX_CHAR_UUID {
                rxCharacteristics = c
                self.peripheral.setNotifyValue(true, for: c)
            }
        })
    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic == rxCharacteristics {
            if let data = characteristic.value, let dataString = String(data: data, encoding: .ascii) {
                let parts = dataString.split(separator: " ")
                if parts.count > 3 {
                    if let hi = Int.init(parts[2], radix: 16),
                        let lo = Int.init(parts[3], radix: 16) {
                        let value = Int(hi << 8 + lo)
                        
                        AppModel.shared.addStateFromOBD2(state: value)
                    }
                }
            }
        }
    }
    
    private func requestDistance() {
        if let c = txCharacteristics,let data = "01 31\r".data(using: .ascii) {
            peripheral.writeValue(data, for: c, type: .withoutResponse)
        }
    }
}

class OBD2Manager: NSObject, CBCentralManagerDelegate {
    private var manager: CBCentralManager? = nil
    private var obd2Device: OBD2Device?
    
    override init() {
        super.init()
        self.manager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            self.manager?.scanForPeripherals(withServices: [OBD2Device.SERVICE_UUID], options: nil)
        default:
            break
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        obd2Device = OBD2Device(peripheral: peripheral)
        self.manager?.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices([OBD2Device.SERVICE_UUID])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        obd2Device = nil
    }
}

