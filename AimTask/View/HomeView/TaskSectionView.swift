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
                
                Button(action: {
                    viewModel.deleteWholeDoc(docId)
                    
                }, label: {
                    Image(systemName: "trash")
                        .foregroundColor(.blue)
                    
                })
                .padding(.trailing)
                
            }
            
            ForEach(tasks) { task in
                TaskItemView(task: task, viewModel: viewModel)
                
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
                TaskModel(locationName:"", dateTime: Date(),taskItems:  ["Task 1", "Task 2"], coordinate: .init(latitude: 0.0, longitude: 0.0), documentID: ""),
            ], docId: [""], viewModel: HomeViewModel()
        )
    }
}
