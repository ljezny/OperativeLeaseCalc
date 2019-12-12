//
//  OBDManager.swift
//  OperativeLeaseCalc
//
//  Created by Lukas Jezny on 28/11/2019.
//  Copyright © 2019 Lukas Jezny. All rights reserved.
//

import UIKit
import CoreBluetooth
import CocoaLumberjack

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
                setupCommands()
                requestDistance()
                sendNextCommand()
            }
            if c.uuid == OBD2Device.RX_CHAR_UUID {
                rxCharacteristics = c
                self.peripheral.setNotifyValue(true, for: c)
            }
        })
    }
    
    var pendingCommands = [String]()
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic == rxCharacteristics {
            if let data = characteristic.value, let dataString = String(data: data, encoding: .ascii) {
                DDLogInfo("OBD2Device: didUpdateValueFor value: \(dataString)" )
                if dataString.starts(with: "01 31\r"){ //response to distance request
                    let dataString = dataString.replacingOccurrences(of: "01 31\r", with: "")
                    //41 31 02 00\r
                    let parts = dataString.split(separator: " ")
                    if parts.count > 3 {
                        if parts[0] == "41", parts[1] == "31", let hi = Int.init(parts[2], radix: 16),
                            let lo = Int.init(parts[3], radix: 16) {
                            let value = Int(hi << 8 + lo)
                            
                            AppModel.shared.addStateFromOBD2(state: value)
                        }
                    }
                }
                
                if pendingCommands.isEmpty {
                    requestDistance()
                }
                
                sendNextCommand()
            }
        }
    }
    
    private func setupCommands() {
        pendingCommands.append("ATZ") //reset
        pendingCommands.append("ATD") //set defaults
        pendingCommands.append("AT ST FF") //set maximum timeout
    }
    
    private func sendNextCommand() {
        if pendingCommands.count > 0 {
            sendCommand(command: pendingCommands.removeFirst())
        }
    }
    
    private func requestDistance() {
        pendingCommands.append("01 31")
    }
    
    private func sendCommand(command:String) {
        if let c = txCharacteristics,let data = "\(command)\r".data(using: .ascii) {
            DDLogInfo("OBD2Device sendCommand: \(command)")
            peripheral.writeValue(data, for: c, type: .withoutResponse)
        }
    }
}

//http://www.splinter.com.au/2019/05/18/ios-swift-bluetooth-le/
class OBD2Manager: NSObject, CBCentralManagerDelegate {
    private var manager: CBCentralManager? = nil
    private var obd2Device: OBD2Device?
    
    static let shared = OBD2Manager()
    
    private override init() {
        super.init()
        self.manager = CBCentralManager(delegate: self, queue: DispatchQueue.main,options:[CBCentralManagerOptionRestoreIdentifierKey:"OBD2Manager"])
    }
    
    func startScanning() {
        DDLogInfo("OBD2Manager: startScanning")
        if let peripheral = self.manager?.retrieveConnectedPeripherals(withServices: [OBD2Device.SERVICE_UUID]).first {
            DDLogInfo("OBD2Manager: startScanning, retrieved peripheral: \(peripheral)")
            obd2Device = OBD2Device(peripheral: peripheral)
            self.manager?.connect(peripheral, options: nil)
        } else {
            DDLogInfo("OBD2Manager: startScanning scanForPeripherals")
            self.manager?.scanForPeripherals(withServices: [OBD2Device.SERVICE_UUID], options: nil)
        }
    }
    
    func stopScanning() {
        DDLogInfo("OBD2Manager: stopScanning")
        self.manager?.stopScan()
    }
    
    func forget() {
        DDLogInfo("OBD2Manager: forget")
        stopScanning()
        
        if let peripheral = obd2Device?.peripheral {
           self.manager?.cancelPeripheralConnection(peripheral)
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            DDLogInfo("OBD2Manager: centralManagerDidUpdateState: poweredOn")
            if let peripheral = obd2Device?.peripheral {
                DDLogInfo("OBD2Manager: centralManagerDidUpdateState: reconnecting restored device")
                self.manager?.connect(peripheral, options: nil)
            } else {
                DDLogInfo("OBD2Manager: centralManagerDidUpdateState: scanning started")
                startScanning()
            }
        case .poweredOff:
            DDLogInfo("OBD2Manager: centralManagerDidUpdateState: poweredOff")
            obd2Device = nil
        default:
            break
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.name != "OBDII" {
            DDLogInfo("OBD2Manager: didDiscover unknown peripheral, will be ignored: \(peripheral)")
            return
        }
        obd2Device = OBD2Device(peripheral: peripheral)
        DDLogInfo("OBD2Manager: didDiscover: \(peripheral)'")
        stopScanning()
        self.manager?.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        DDLogInfo("OBD2Manager: didConnect: \(peripheral)'")
        peripheral.discoverServices([OBD2Device.SERVICE_UUID])
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        DDLogInfo("OBD2Manager: didFailToConnect: \(peripheral) error:\(String(describing: error))")
        
        if let error = error {
            DDLogInfo("OBD2Manager: didFailToConnect due to error:\(error)")
            obd2Device = nil
        }
        
        if let peripheral = obd2Device?.peripheral {
            DDLogInfo("OBD2Manager: didFailToConnect: reconnecting failed device")
            self.manager?.connect(peripheral, options: nil)
        } else {
            startScanning()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        DDLogInfo("OBD2Manager: didDisconnectPeripheral: \(peripheral)'")
        
        if let error = error {
            DDLogInfo("OBD2Manager: didDisconnectPeripheral error, will re-connect: \(error)")
            self.manager?.connect(peripheral, options: nil)
            
            AppModel.shared.onOBDDisconnected()
        } else {
            obd2Device = nil
        }
    }
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        DDLogInfo("OBD2Manager: willRestoreState: \(dict)'")
        if let peripherals = dict[CBCentralManagerRestoredStatePeripheralsKey] as? [CBPeripheral], let peripheral = peripherals.first {
            obd2Device = OBD2Device(peripheral: peripheral)
        }
    }

}

