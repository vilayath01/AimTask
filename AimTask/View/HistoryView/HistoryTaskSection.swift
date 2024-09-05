//
//  HistoryTaskSection.swift
//  AimTask
//
//  Created by Vilayath Mohammed on 5/9/2024.
//

import Foundation
import SwiftUI

struct HistoryTaskSection: View {
    @State var isSelected: Bool = false
    var viewModel: HistoryViewModel
    var task: TaskModel
    var title: String
    var subtitle: String
  
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(title)
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .padding(.leading)
                
                Spacer()
                
                Button(action: {
                    viewModel.saveHistory(docId: task.documentID, isSave: false)
                }, label: {
                    Image(systemName: "trash")
                })
            }
            
            Text(subtitle)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .padding(.leading)
                .padding(.top, 5)
            
            HistoryTaskItem(taskItems: task.taskItems)
            
            HStack {
                Spacer()
                Button(action: {
                    isSelected.toggle()
                }, label: {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "checkmark.circle")
                })
            }
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.7))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }
}
