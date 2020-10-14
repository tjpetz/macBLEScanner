//
//  BLEClasses.swift
//  BLETest
//
//  Created by Thomas Petz, Jr. on 10/12/20.
//

import Foundation
import CoreBluetooth

let BLE_EnvironmentalService_CBUUID = CBUUID(string: "0x181A");

extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }

    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return map { String(format: format, $0) }.joined()
    }
}

class Descriptor: NSObject, ObservableObject, Identifiable {
    let descriptor: CBDescriptor
    
    init (_ descriptor: CBDescriptor) {
        self.descriptor = descriptor
    }
}

class Characteristic: NSObject, ObservableObject, Identifiable {
    let characteristic: CBCharacteristic
    @Published var value: Data?
    @Published var descriptors: [Descriptor] = []
    
    func findDescriptor(_ descriptor: CBDescriptor) -> Descriptor? {
        for d in descriptors {
            if d.descriptor.uuid == descriptor.uuid {
                return d
            }
        }
        return nil
    }
    
    init (_ characteristic: CBCharacteristic) {
        self.characteristic = characteristic
    }
}

class Service: NSObject, ObservableObject, Identifiable {
    let service: CBService
    @Published var characteristics: [Characteristic] = []
    
    func findCharacteristic(_ characteristic: CBCharacteristic) -> Characteristic? {
        for c in characteristics {
            if c.characteristic.uuid == characteristic.uuid {
                return c
            }
        }
        return nil
    }
    
    init(_ service: CBService) {
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


// Support scanning for peripherals and maintain a collection
// of discovered peripherals.
class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var myCentral: CBCentralManager!
    @Published var peripherals: [Peripheral] = []
    @Published var isScanning = false
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
    }
    
    func startScan() {
        print("Starting scan")
        isScanning = true
        myCentral.scanForPeripherals(
            withServices: nil,
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
    }
    
    func stopScan() {
        print("Stopping scan")
        isScanning = false
        myCentral.stopScan()
    }
        
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String:Any], rssi RSSI: NSNumber) {
        print("Found a peripheral")
        print(RSSI.intValue)
        print(peripheral)
        
        var known = false
        var item = 0

        // check to see if we've seen this peripheral before
        for (i, p) in peripherals.enumerated() {
            if (p.peripheral.identifier == peripheral.identifier) {
                known = true
                item = i
            }
        }

        let txPower = advertisementData[CBAdvertisementDataTxPowerLevelKey] is Int ?
            advertisementData[CBAdvertisementDataTxPowerLevelKey] as! Int : 0

        if (!known) {
            peripherals.append(Peripheral(peripheral: peripheral, rssi: RSSI.intValue, txPower: txPower))
        } else {
            // update with the latest data
            peripherals[item] = Peripheral(peripheral: peripheral, rssi: RSSI.intValue, txPower: txPower)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // find the services
        print("Peripheral \(peripheral.identifier.uuidString) connected - start discovering services")
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let p = self.findPeripheral(peripheral) {
            print("Disconnected")
            p.connected = false
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("Found \(peripheral.services!.count) services for \(peripheral.identifier.uuidString)")
        
        if let p = self.findPeripheral(peripheral) {
            p.foundServices = true
            p.connected = true
            p.services = []
            for s in peripheral.services! {
                p.services.append(Service(s))
                // discover the characteristics for this service
                p.peripheral.discoverCharacteristics(nil, for: s)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("Found \(service.characteristics!.count) characteristics for service \(service.uuid.uuidString)")
        
        if let p = self.findPeripheral(peripheral) {
            if let s = p.findService(service) {
                s.characteristics = []
                for c in service.characteristics! {
                    // trigger a read of the characterisitic if readable
                    if c.properties.contains(.read) {
                        peripheral.readValue(for: c)
                    }
                    // Addit to our list
                    s.characteristics.append(Characteristic(c))
                    // discover the descriptors for this characteristic
                    p.peripheral.discoverDescriptors(for: c)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        print("Found \(characteristic.descriptors!.count) descriptors for characteristic \(characteristic.uuid.uuidString)")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("Updated value of \(characteristic.value.debugDescription) for \(characteristic.uuid.uuidString) of \(peripheral.identifier.uuidString)")
        print("Hex value = \(characteristic.value?.hexEncodedString() ?? "unknown")")
        if let p = self.findPeripheral(peripheral) {
            if let s = p.findService(characteristic.service) {
                if let c = s.findCharacteristic(characteristic) {
                    c.value = characteristic.value
                }
            }
        }
    }
    
    // find an existing peripheral or return nil
    func findPeripheral(_ peripheral: CBPeripheral) -> Peripheral? {
        var pExists: Peripheral? = nil
        
        for p in peripherals {
            if (p.peripheral.identifier == peripheral.identifier) {
                pExists = p
            }
        }
        
        return pExists
    }
    
    override init() {
        super.init()
        
        myCentral = CBCentralManager(delegate: self, queue: nil)
    }
}

