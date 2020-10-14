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
                Text("Services")
            }
            NavigationView {
                List (peripheral.services) {
                    service in
                    NavigationLink (destination: ServiceView(peripheral: peripheral, service: service)) {
                        Text(service.service.uuid.uuidString)
                        }
                    }
            }
        }.frame(minWidth: 300)
        .onAppear(perform: {manager.myCentral.connect(peripheral.peripheral)})
        .onDisappear(perform: {manager.myCentral.cancelPeripheralConnection(peripheral.peripheral)})
    }
    
}

//struct PeripheralView_Previews: PreviewProvider {
//    static var previews: some View {
//        PeripheralView()
//    }
//}
