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
    @ObservedObject var fdbManager: FDBManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                if let task = tasks.first(where: { $0.locationName == title }) {
                    styledText(title, fontSize: 18)
                        
                        .fontWeight(task.enteredGeofence ? .bold : .semibold)
                      
                        .padding(.leading)
                        .padding(.top, 10)
                        .padding(.bottom, 5)
                       
                } else {
                    styledText(title, fontSize: 18, isBold: false)
                        .padding(.leading)
                        .padding(.top, 10)
                        .padding(.bottom, 5)
                }
                
                
                Spacer()
                
                if let task = tasks.first(where: { $0.locationName == title }) {
                    Button(action: {
                        if task.enteredGeofence {
                            // Perform checkmark-related action
                            viewModel.saveHistory(docId: task.documentID, isSave: true, locationName: task.locationName, isPositive: true)
                            fdbManager.completedTaskDateTime(from: task.documentID, dateTime: Date())
                        } else {
                            viewModel.deleteWholeDoc(docId, locationName: task.locationName, isPositive: false)
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
                TaskItemView(viewModel: viewModel, fdbManager: fdbManager, task: task)
                
            }
        }
        .padding()
        .background(Color.white.opacity(0.7))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }
    
}

struct TaskSectionView_Previews: PreviewProvider {
    static var previews: some View {
        TaskSectionView(
            title: "Example: 510 glenferrie Road, Hawthorn,Australia.",
            tasks: [
                TaskModel(locationName:"", addTaskDateTime: Date(), completedTaskDateTime: Date(),taskItems:  ["Task 1", "Task 2"], coordinate: .init(latitude: 0.0, longitude: 0.0), documentID: "", enteredGeofence: false, saveHistory: false),
            ], docId: [""], viewModel: HomeViewModel(), fdbManager: FDBManager()
        )
    }
}
