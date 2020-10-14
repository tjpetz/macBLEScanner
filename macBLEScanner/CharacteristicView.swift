//
//  CharacteristicView.swift
//  macBLEScanner
//
//  Created by Thomas Petz, Jr. on 10/13/20.
//

import SwiftUI

struct CharacteristicView: View {
    @ObservedObject var characteristic: Characteristic

    var body: some View {
        VStack {
            Text("Descriptors").font(.footnote)
            List (characteristic.characteristic.descriptors ?? [], id: \.uuid) {
                descriptor in
                Text(descriptor.uuid.uuidString)
            }
            Spacer()
        }.frame(minWidth: 300)
    }
}

//struct CharacteristicView_Previews: PreviewProvider {
//    static var previews: some View {
//        CharacteristicView()
//    }
//}
