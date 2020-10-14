//
//  ContentView.swift
//  BLETest
//
//  Created by Thomas Petz, Jr. on 10/9/20.
//

import SwiftUI
import CoreBluetooth

struct ContentView: View {
    
    @ObservedObject var bleManager = BLEManager()
    
    var body: some View {
        VStack  ( spacing: 10) {
            Text("Devices")
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
