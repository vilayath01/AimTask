//
//  HomeView.swift
//  AimTask
//
//  Created by Vilayath Mohammed on 22/7/2024.
//


import SwiftUI

struct TaskItem: View {
    var body: some View {
        HStack {
            Circle()
                .fill(Color.purple)
                .frame(width: 30, height: 30)
                .overlay(Text("A").foregroundColor(.white).font(.headline))
            Text("List item")
                .font(.body)
                .foregroundColor(.primary)
            Spacer()
            Image(systemName: "checkmark.square.fill")
                .foregroundColor(.purple)
        }
        .padding()
        .background(Color(red: 105/255, green: 155/255, blue: 157/255).opacity(0))
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.4), radius: 5, x: 0, y: 2)
    }
}

struct TaskSection: View {
    var title: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .padding(.leading)
                .padding(.top, 10)
            
            
            ForEach(0..<4) { _ in
                TaskItem()
            }
        }
        .background(Color(red: 105/255, green: 155/255, blue: 157/255).opacity(1))
        .cornerRadius(10)
        .padding()
    }
}

struct HomeView: View {
    var body: some View {
        NavigationView {

                ScrollView {
                    VStack(spacing: 20) {
                        TaskSection(title: "Location One Task")
                        TaskSection(title: "Location Two Task")
                        TaskSection(title: "Location Three Task")
                    }
                    .padding(.top)
                   
                }
          
            .navigationTitle("Home")
            .background(Color(red: 105/255, green: 155/255, blue: 157/255).ignoresSafeArea())
        }
       
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
