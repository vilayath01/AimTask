//
//  TaskItemView.swift
//  AimTask
//
//  Created by Vilayath Mohammed on 18/8/2024.
//

import Foundation
import SwiftUI

struct TaskItemView: View {
    @ObservedObject var viewModel: HomeViewModel
    @State private var newTaskText: String = ""
    @State private var isAddingTask: Bool = false
    @State private var isPresented: Bool = false
    
    var task: TaskModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                // Existing tasks
                ForEach(task.taskItems.indices, id: \.self) { index in
                    let alphabet = String(UnicodeScalar(65 + index)!)
                    
                    HStack {
                        Circle()
                            .fill(Color.black)
                            .frame(width: 30, height: 30)
                            .overlay(Text(alphabet)
                                .foregroundColor(.white)
                                .font(.headline))
                        
                        styledText(task.taskItems[index], fontSize: 14, isBold: task.enteredGeofence)
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.deleteTask(from: task.documentID, item: task.taskItems[index])
                        }) {
                            Image(systemName: "trash")
                        }
                        .foregroundColor(.red)
                        
                    }
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: task.enteredGeofence ? [Color.green.opacity(0.2), Color.blue.opacity(0.2)] : [Color.gray.opacity(0.2), Color.blue.opacity(0.2)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .cornerRadius(10)
                    )
                    .shadow(color: task.enteredGeofence ? Color.green.opacity(0.5) : Color.black.opacity(0.2), radius: 4, x: 2, y: 2)
                }
                
                // Add new task section
                if isAddingTask {
                    HStack {
                        TextField("Add new task", text: $newTaskText)
                            .padding(10)
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(8)
                            .font(.custom("Avenir", size: 14))
                            .bold()
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                            )
                            .padding(.horizontal)
                        
                        Button(action: {
                            if !newTaskText.isEmpty {
                                viewModel.addTaskItem(from: task.documentID, item: newTaskText)
                                newTaskText = ""
                                isAddingTask = false
                            }
                        }) {
                            Image(systemName: "checkmark")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 16, height: 16)
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.green)
                                .clipShape(Rectangle())
                                .cornerRadius(4)
                                .shadow(color: .gray, radius: 2, x: 0, y: 2)
                            
                        }
                    }
                    .padding()
                }
                
                // Add Task button
                HStack {
                    Button(action: {
                        isAddingTask.toggle()
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                            styledText(HomeViewString.addTask.localized, fontSize: 16, textColor: .blue)
                                .padding(.leading, 5)
                        }
                    }
                    .padding(.top)
                    
                    Spacer()
                    if !task.enteredGeofence {
                        Menu {
                            Button(action: {
                                // Directly save to history without confirmation dialog
                                viewModel.saveHistory(docId: task.documentID, isSave: true, locationName: task.locationName, isPositive: true)
                            }) {
                                Label(HomeViewString.completedTask.localized, systemImage: "checkmark.circle")
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.title)
                                .foregroundColor(.gray)
                                .padding(.trailing)
                                .padding(.top)
                        }
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
        TaskItemView(viewModel: HomeViewModel(), task: TaskModel(locationName: "", dateTime: Date(), taskItems: ["Task 1", "Task 2"], coordinate: .init(latitude: 0.0, longitude: 0.0), documentID: "", enteredGeofence: false, saveHistory: false))
    }
}
