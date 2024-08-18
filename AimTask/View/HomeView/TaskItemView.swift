//
//  TaskItemView.swift
//  AimTask
//
//  Created by Vilayath Mohammed on 18/8/2024.
//

import Foundation
import SwiftUI

struct TaskItemView: View {
    @State private var completedItems = Set<String>() // Track completed items
    let task: TaskModel
    
    var body: some View {
        HStack {
           
            
            VStack(alignment: .leading, spacing: 2) {
                ForEach(task.taskItems.indices, id: \.self) { index in
                          let alphabet = String(UnicodeScalar(65 + index)!)
                          Button(action: {
                              toggleItemCompletion(task.taskItems[index])
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
                                      .foregroundColor(completedItems.contains(task.taskItems[index]) ? .secondary : .primary)
                                      .strikethrough(completedItems.contains(task.taskItems[index]), color: .secondary)
                                  Spacer()
                                  Image(systemName: completedItems.contains(task.taskItems[index]) ? "checkmark.square.fill" : "square")
                                      .foregroundColor(completedItems.contains(task.taskItems[index]) ? .purple : .secondary)
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
                          .swipeActions {
                              Button(role: .destructive) {
                                  deleteItem(task.taskItems[index])
                              } label: {
                                  Label("Delete", systemImage: "trash")
                              }
                          }
                          .padding(.vertical, 4) // Add spacing between buttons
                      }
                  }
            
            Spacer()
        }
        .padding()
        .background(Color.clear)
        .cornerRadius(8)
    }
    
    private func toggleItemCompletion(_ item: String) {
        if completedItems.contains(item) {
            completedItems.remove(item)
        } else {
            completedItems.insert(item)
        }
    }
    
    private func deleteItem(_ item: String) {
        // Handle deletion logic here
    }
}

struct TaskItemView_Previews: PreviewProvider {
    static var previews: some View {
        TaskItemView(task: TaskModel(locationName:"", dateTime: Date(),taskItems:  ["Task 1", "Task 2"], coordinate: .init(latitude: 0.0, longitude: 0.0), documentID: ""))
    }
}
