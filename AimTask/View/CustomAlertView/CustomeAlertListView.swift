//
//  CustomeAlertListView.swift
//  AimTask
//
//  Created by Vilayath Mohammed on 17/8/2024.
//

import SwiftUI

struct CustomAlertListView: View {
    @Binding var taskItem: String
    var isLast: Bool
    var isFirst: Bool
    var onAdd: (() -> Void)?
    var onRemove: (() -> Void)?
    var showRemoveButton: Bool
    
    var body: some View {
        HStack {
            Circle()
                .frame(width: 33, height: 33)
                .foregroundColor(.cyan)
                .overlay(Text("✔️").foregroundColor(.white))
            
            TextField(CustomAlertString.listItemPlaceholder.localized, text: $taskItem)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(.leading, 4)
                .font(.custom("Avenir", size: 16))
                .bold()
                
            
            Spacer()
            
            if isLast {
                Button(action: {
                    onAdd?() // Safely call onAdd closure
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(taskItem.isEmpty ? .gray : .blue)
                        .padding(.trailing, 4)
                }
                .disabled(taskItem.isEmpty)
                .buttonStyle(PlainButtonStyle())
            }
            
            if showRemoveButton {
                Button(action: {
                    onRemove?() // Safely call onRemove closure
                }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.red)
                        .padding(.trailing, 4)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.vertical, 2)
    }
}
