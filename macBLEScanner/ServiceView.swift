//
//  ServiceView.swift
//  BLETest
//
//  Created by Thomas Petz, Jr. on 10/12/20.
//

import SwiftUI
import CoreBluetooth

struct ServiceView: View {
    @ObservedObject var service: Service
    
    var body: some View {
        VStack {
            Text("Characteristics").font(.footnote)
            NavigationView {
                List (service.characteristics) {
                    characteristic in
                    CharacteristicCell(characteristic: characteristic)
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
    @ObservedObject var characteristic: Characteristic
    
    var body: some View {
        VStack {
                VStack {
                NavigationLink (destination: CharacteristicView(characteristic: characteristic)) {
                        Text(characteristic.characteristic.uuid.uuidString)
                }.disabled(characteristic.characteristic.descriptors?.count == 0)
            }
            VStack {
                Text("Notifying: \(characteristic.characteristic.isNotifying ? "True" : "False")").font(.footnote)
                HStack {
                    Button("Read", action: {})
                    Button("Write", action: {})
                    Button("Subscribe", action: {})
                }
            }
        }
    }
}
