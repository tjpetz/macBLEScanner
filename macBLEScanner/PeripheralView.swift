//
//  PeripheralView.swift
//  BLETest
//
//  Created by Thomas Petz, Jr. on 10/12/20.
//

import SwiftUI
import CoreBluetooth

struct PeripheralView: View {
    @ObservedObject var manager: BLEManager
    @ObservedObject var peripheral: Peripheral
    
    var body: some View {
        VStack {
            VStack {
                Text(peripheral.peripheral.identifier.uuidString)
                Text(peripheral.peripheral.name ?? "")
            }
            NavigationView {
            List (peripheral.services) {
                service in
                NavigationLink (destination: ServiceView(service: service)) {
                    Text(service.service.uuid.uuidString)
                    }
                }
            }

            HStack {
                    Button("Connect", action: {manager.myCentral.connect(peripheral.peripheral)})
                        .disabled(peripheral.peripheral.state == .connected)
                    Button("Disconnect", action: {manager.myCentral.cancelPeripheralConnection(peripheral.peripheral)})
                        .disabled(peripheral.peripheral.state != .connected)
                }
        }.frame(minWidth: 300)
    }
}

//struct PeripheralView_Previews: PreviewProvider {
//    static var previews: some View {
//        PeripheralView()
//    }
//}
