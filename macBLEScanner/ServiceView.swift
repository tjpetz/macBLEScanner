//
//  ServiceView.swift
//  BLETest
//
//  Created by Thomas Petz, Jr. on 10/12/20.
//

import SwiftUI

struct ServiceView: View {
    @ObservedObject var service: Service
    
    var body: some View {
        VStack {
            Text(service.service.uuid.uuidString)
            Text("Characteristics").font(.footnote)
            List (service.characteristics, id: \.uuid) {
                characteristic in
                Text(characteristic.uuid.uuidString)
                Text("Notifying: \(characteristic.isNotifying ? "True" : "False")")
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
