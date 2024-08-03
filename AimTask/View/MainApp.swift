//
//  ContentView.swift
//  AimTask
//
//  Created by Vilayath Mohammed on 20/7/2024.
//

import SwiftUI
import CoreLocation

struct MainApp: View {
    @ObservedObject var viewModel = TaskViewModel()
    
    var body: some View {       
        TabView {
            HomeView() .tabItem {
                Label("Home", systemImage: "house")
            }
            AddTaskView().tabItem {
                Label("Add Task", systemImage: "target")
            }
            HistoryView().tabItem {
                Label("History", systemImage: "calendar.badge.clock")
                 
            }
            
        }
    }
}

#Preview {
    MainApp()
}
