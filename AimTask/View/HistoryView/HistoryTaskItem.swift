//
//  HistoryTaskItem.swift
//  AimTask
//
//  Created by Vilayath Mohammed on 5/9/2024.
//

import Foundation
import SwiftUI

struct HistoryTaskItem: View {
    
    var taskItems: [String]
    
    var body: some View {
        VStack (alignment: .leading){
            
            ForEach (taskItems, id: \.self) { task in
                styledText("✅ : \(task) ", fontSize: 16, isBold: false)
                    
            }
        }
        .padding(.leading)
        .padding(.top, 10)
    }
}

#Preview {
    HistoryTaskItem(taskItems: ["This is example1", "This is example2"])
}
