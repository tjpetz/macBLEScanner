//
//  ServiceView.swift
//  BLETest
//
//  Created by Thomas Petz, Jr. on 10/12/20.
//

import SwiftUI
import CoreBluetooth

struct ServiceView: View {
    @ObservedObject var peripheral: Peripheral
    @ObservedObject var service: Service
    
    var body: some View {
        VStack {
            Text("Characteristics").font(.footnote)
            NavigationView {
                List (service.characteristics) {
                    characteristic in
                    CharacteristicCell(peripheral: peripheral, characteristic: characteristic)
                }
            }
            Spacer()
        }.frame(minWidth: 300)
    }
}

//struct ServiceView_Previews: PreviewProvider {
//    static var previews: some View {
//        ServiceView()
//    }
//}

struct CharacteristicCell: View {
    @ObservedObject var peripheral: Peripheral
    @ObservedObject var characteristic: Characteristic
    
    var body: some View {
        VStack {
            Text(characteristic.characteristic.uuid.uuidString)
            Text("Value = \(characteristic.value?.hexEncodedString() ?? "-")")
            HStack {
                Button("Read",
                       action: {peripheral.peripheral.readValue(for: characteristic.characteristic)}
                ).disabled(!characteristic.characteristic.properties.contains(.read))
                Button("Write", action: {}).disabled(!characteristic.characteristic.properties.contains(.write))
                Button("Subscribe", action: {}).disabled(!characteristic.characteristic.properties.contains(.notify))
            }
        }.onAppear(perform: {
            // Read the value if it's readable
            if characteristic.characteristic.properties.contains(.read) {
                peripheral.peripheral.readValue(for: characteristic.characteristic)
            }
            })
    }
}
