//
//  ErrorBar.swift
//  AimTask
//
//  Created by Vilayath Mohammed on 7/9/2024.
//

import Foundation
import SwiftUI

struct ErrorBarView: View {
    @Binding var errorMessage: String
    @Binding var isPositive: Bool
    
    var body: some View {
        if !errorMessage.isEmpty {
            HStack {
                Text(errorMessage)
                    .foregroundColor(.white)
                    .padding()
                    .background(isPositive ? Color.green.opacity(0.8) : Color.red.opacity(0.8))
                    .cornerRadius(8)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 5)
            .transition(.move(edge: .top).combined(with: .opacity))
            .animation(.easeInOut)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    errorMessage = ""
                }
            }
        }
    }
}

struct ErrorBarView_Previews: PreviewProvider {
    @State static var message = "This is an invalid email address. Please try again with the correct email address."
    @State static var isPositive = true
    
    static var previews: some View {
        ErrorBarView(errorMessage: $message, isPositive: $isPositive)
    }
}
