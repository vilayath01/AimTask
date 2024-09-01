//
//  TaskSectionView.swift
//  AimTask
//
//  Created by Vilayath Mohammed on 18/8/2024.
//

import Foundation
import SwiftUI

struct TaskSectionView: View {
    var title: String
    var tasks: [TaskModel]
    var docId: [String]
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .padding(.leading)
                    .padding(.top, 10)
                
                Spacer()
                
                if let task = tasks.first(where: { $0.locationName == title }) {
                    Button(action: {
                        if task.enteredGeofence {
                            // Perform checkmark-related action
                        } else {
                            viewModel.deleteWholeDoc(docId)
                        }
                    }, label: {
                        Image(systemName: task.enteredGeofence ? "checkmark" : "trash")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 16, height: 16)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(task.enteredGeofence ? Color.green : Color.red)
                            .clipShape(Rectangle())
                            .cornerRadius(4)
                            .shadow(color: .gray, radius: 2, x: 0, y: 2)
                        
                    })
                    .padding(.trailing)
                }
            }
            
            ForEach(tasks) { task in
                TaskItemView(viewModel: viewModel, task: task)
                
            }
        }
        .background(Color(red: 105/255, green: 155/255, blue: 157/255).opacity(1))
        .cornerRadius(10)
        .padding()
    }
    
}

struct TaskSectionView_Previews: PreviewProvider {
    static var previews: some View {
        TaskSectionView(
            title: "Example: 510 glenferrie Road, Hawthorn,Australia.",
            tasks: [
                TaskModel(locationName:"", dateTime: Date(),taskItems:  ["Task 1", "Task 2"], coordinate: .init(latitude: 0.0, longitude: 0.0), documentID: "", enteredGeofence: false),
            ], docId: [""], viewModel: HomeViewModel()
        )
    }
}
