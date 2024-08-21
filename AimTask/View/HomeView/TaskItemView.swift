//
//  TaskItemView.swift
//  AimTask
//
//  Created by Vilayath Mohammed on 18/8/2024.
//

import Foundation
import SwiftUI

struct TaskItemView: View {
    let task: TaskModel
    
    @ObservedObject var viewModel: HomeViewModel
    @State var enteredToLocation: Bool = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                
                ForEach(task.taskItems.indices, id: \.self) { index in
                    let alphabet = String(UnicodeScalar(65 + index)!)
                    
                    Button(action: {
                        viewModel.toggleItemCompletion(task.taskItems[index])
                    }) {
                        HStack {
                            Circle()
                                .fill(Color.purple)
                                .frame(width: 30, height: 30)
                                .overlay(Text(alphabet)
                                    .foregroundColor(.white)
                                    .font(.headline))
                            
                            Text(task.taskItems[index])
                                .font(.subheadline)
                                .foregroundColor(enteredToLocation ? (viewModel.completedItems.contains(task.taskItems[index]) ? .secondary : .primary) : .primary)
                                .strikethrough( enteredToLocation && viewModel.completedItems.contains(task.taskItems[index]), color: .secondary)
                            
                            Spacer()
                            
                            if enteredToLocation {
                                Image(systemName: viewModel.completedItems.contains(task.taskItems[index]) ? "checkmark.square.fill" : "square")
                                    .foregroundColor(viewModel.completedItems.contains(task.taskItems[index]) ? .purple : .secondary)
                            } else {
                                Button(action: {
                                    viewModel.deleteTask(from: task.documentID, item: task.taskItems[index])
                                }) {
                                    Image(systemName: "trash")
                                }
                                .foregroundColor(.red)
                            }
                            
                        }
                        .padding()
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.2), Color.blue.opacity(0.2)]),
                                           startPoint: .leading,
                                           endPoint: .trailing)
                            .cornerRadius(10)
                        )
                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 2, y: 2)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color.clear)
        .cornerRadius(8)
    }
    
    
}

struct TaskItemView_Previews: PreviewProvider {
    static var previews: some View {
        TaskItemView(task: TaskModel(locationName:"", dateTime: Date(),taskItems:  ["Task 1", "Task 2"], coordinate: .init(latitude: 0.0, longitude: 0.0), documentID: ""), viewModel: HomeViewModel())
    }
}
