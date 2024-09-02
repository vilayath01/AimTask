//
//  NoTaskaView.swift
//  AimTask
//
//  Created by Vilayath Mohammed on 18/8/2024.
//

import Foundation
import SwiftUI

struct NoTasksView: View {
    @State var taskViewToShow: Bool
    var body: some View {
        VStack {
            Text(taskViewToShow ? "No tasks added🙁" : "Good Luck!😉")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding()
            
            Text(taskViewToShow ? "It looks like you haven't added any tasks yet!" : "Complete the task to share it with friends!")
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
        NoTasksView(taskViewToShow: true)
    }
}
