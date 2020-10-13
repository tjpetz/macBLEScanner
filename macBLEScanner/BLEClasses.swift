//
//  BLEClasses.swift
//  BLETest
//
//  Created by Thomas Petz, Jr. on 10/12/20.
//

import Foundation
import CoreBluetooth

let BLE_EnvironmentalService_CBUUID = CBUUID(string: "0x181A");

class Characteristic: NSObject, ObservableObject, Identifiable {
    let characteristic: CBCharacteristic
    
    init (characteristic: CBCharacteristic) {
        self.characteristic = characteristic
    }
}

class Service: NSObject, ObservableObject, Identifiable {
    let service: CBService
    @Published var characteristics: [CBCharacteristic] = []
    
    init(service: CBService) {
        self.service = service
    }
}

// Wrap a CBPeripheral as an ObservableObject
class Peripheral: NSObject, ObservableObject, Identifiable {
    
    let peripheral: CBPeripheral
    var rssi: Int = 0
    var txPower: Int = 0
    @Published var foundServices = false;
    @Published var services: [Service] = []
    @Published var connected = false
    
    func findService(_ service: CBService) -> Service? {
        for s in services {
            if s.service.uuid == service.uuid {
                return s
            }
        }
        return nil
    }

    init(peripheral: CBPeripheral, rssi: Int, txPower: Int) {
        self.peripheral = peripheral
        self.rssi = rssi
        self.txPower = txPower
    }
}

