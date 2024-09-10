//
//  ErrorScreen.swift
//  AimTask
//
//  Created by Vilayath Mohammed on 2/9/2024.
//

import Foundation
import SwiftUI

struct SomethingWentWrongView: View {
    var retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Replace "app_logo" with your actual app logo asset name
                Image(systemName: "network.slash")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
            
            styledText("Looks like you're not connected to world!", fontSize: 20)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            Button(action: retryAction) {
                Text("Okay")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.gray)
                    .cornerRadius(30)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.brown.opacity(0.3), lineWidth: 1)
                    )
            }
        }
        .padding()
        .background(Color(red: 105/255, green: 155/255, blue: 157/255))
        .cornerRadius(20)
        .shadow(radius: 10)
        .frame(maxWidth: 300)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        
    }
        
}

struct SomethingWentWrongCardView_Previews: PreviewProvider {
    static var previews: some View {
        SomethingWentWrongView(retryAction: {

        })
            .background(Color.gray.opacity(0.2).edgesIgnoringSafeArea(.all)) 
    }
}
