//
//  NoTaskaView.swift
//  AimTask
//
//  Created by Vilayath Mohammed on 18/8/2024.
//

import Foundation
import SwiftUI

enum NoTasksViewString {
    static let goodLuckTitle = "good_luck_title"
    static let goodLuckDescription = "good_luck_description"
    static let noTaskCompletedYetTitle = "no_task_completed_yet_title"
    static let noTaskCompletedYetDescription = "no_task_completed_yet_description"
}

struct NoTasksView: View {
    @State var taskViewToShow: Bool
    var body: some View {
        VStack() {
            styledText(
                taskViewToShow
                    ? NoTasksViewString.goodLuckTitle.localized
                    : NoTasksViewString.noTaskCompletedYetTitle.localized
            )
                .padding(.top, taskViewToShow ? 0 : 200)

            
            styledText(taskViewToShow ? NoTasksViewString.goodLuckDescription.localized : NoTasksViewString.noTaskCompletedYetDescription.localized, fontSize: 18)
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
