//
//  PrivacyScreen.swift
//  AimTask
//
//  Created by vila on 9/9/2024.
//

import Foundation
import SwiftUI

struct PrivacyView: View {
    var body: some View {
        VStack(alignment: .center) {
            Image("logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding([.leading, .trailing], 30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.aimTaskBackground)
        .ignoresSafeArea()  // This will extend the background to the safe area edges
    }
}

#Preview {
    PrivacyView()
}
