//
//  CustomeAlertListView.swift
//  AimTask
//
//  Created by Vilayath Mohammed on 17/8/2024.
//

import Foundation
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
                .overlay(Text("A").foregroundColor(.white))
            
            TextField("List item", text: $taskItem)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(.leading, 4)
            
            Spacer()
            
            if isLast {
                Button(action: {
                    onAdd?()
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                        .padding(.trailing, 4)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            if showRemoveButton  {
                Button(action: {
                    onRemove?()
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
