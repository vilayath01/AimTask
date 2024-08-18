//
//  NoTaskaView.swift
//  AimTask
//
//  Created by Vilayath Mohammed on 18/8/2024.
//

import Foundation
import SwiftUI

struct NoTasksView: View {
    var body: some View {
        VStack {
            Text("No tasks added🙁")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding()
            
            Text("It looks like you haven't added any tasks yet!")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 105/255, green: 155/255, blue: 157/255))
        .ignoresSafeArea()
    }
}

struct NoTasksView_Previews: PreviewProvider {
    static var previews: some View {
       NoTasksView()
    }
}
