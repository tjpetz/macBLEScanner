//
//  ContentView.swift
//  BLETest
//
//  Created by Thomas Petz, Jr. on 10/9/20.
//

import SwiftUI
import CoreBluetooth


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
        for p in peripherals {
            if (p.peripheral.identifier == peripheral.identifier ) {
                print("Disconnected")
                p.connected = false
            }
        }

    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("In manager Found \(peripheral.services!.count) services for \(peripheral.identifier.uuidString)")
        
        if let p = self.findPeripheral(peripheral) {
            p.foundServices = true
            p.connected = true
            p.services = []
            for s in peripheral.services! {
                p.services.append(Service(service: s))
                // discover the characteristics for this service
                p.peripheral.discoverCharacteristics(nil, for: s)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        print("In manager found characteristics for service \(service.uuid.uuidString)")
        
        if let p = self.findPeripheral(peripheral) {
            if let s = p.findService(service) {
                s.characteristics = []
                for c in service.characteristics! {
                    s.characteristics.append(c)
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
        myCentral.delegate = self
    }
}

struct ContentView: View {
    
    @ObservedObject var bleManager = BLEManager()
    
    var body: some View {
        VStack  ( spacing: 10) {
            NavigationView {
                List (bleManager.peripherals) { peripheral in
                    PeripheralCell(manager: bleManager, peripheral: peripheral)
                        }
            }
            Text("\(bleManager.peripherals.count) devices")
            HStack {
                Button("Scan", action: {bleManager.startScan()})
                    .disabled(bleManager.isScanning)
                Button("Stop Scan", action: {bleManager.stopScan()})
                    .disabled(!bleManager.isScanning)
            }
        }.frame(minWidth: 300).padding(4)
    }
}

struct PeripheralCell: View {
    var manager: BLEManager
    var peripheral: Peripheral
    
    var body: some View {
        NavigationLink(destination: PeripheralView(manager: manager, peripheral: peripheral)) {
            VStack {
                HStack {
                    Text(peripheral.peripheral.identifier.uuidString)
                    Spacer()
                    Text(peripheral.peripheral.name ?? "")
                    Spacer()
                 }
                HStack {
                    Text("Advertised TX power: \(peripheral.txPower) dBm")
                    Spacer()
                    Text("rssi: \(peripheral.rssi) dBm")
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
