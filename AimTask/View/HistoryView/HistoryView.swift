//
//  HomeView.swift
//  AimTask
//
//  Created by Vilayath Mohammed on 22/7/2024.
//


import SwiftUI
import Combine

struct HistoryTaskItem: View {
    
    var body: some View {
        VStack (alignment: .leading){
            Text("✅ : ")
                .font(.body)
                .foregroundColor(.primary)
        }
        .padding(.leading)
        .padding(.top, 10)
    }
}

struct HistoryTaskSection: View {
    @State var isSelected: Bool = false
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
            
            
            ForEach(0..<4) { _ in
                HistoryTaskItem()
            }
         
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

struct HistoryView: View {
    @StateObject var historyViewModel = HistoryViewModel(loginViewModel: LoginViewModel())
    @StateObject private var networkMonitor = NetworkMonitor()
    @State private var showSomethingWentWrong = false
    @State private var enteredEmail: String = ""
    @State private var readyToSend: Bool = false
    
    var body: some View {
        ZStack {
            NavigationView {
                VStack {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            if historyViewModel.tasks.isEmpty {
                                NoTasksView(taskViewToShow: false)
                                    .frame(maxHeight: .infinity)
                            } else {
                                HistoryTaskSection(title: "Location: ", subtitle: "Date & Time: ")
                                HistoryTaskSection(title: "Location: ", subtitle: "Date & Time: ")
                                HistoryTaskSection(title: "Location: ", subtitle: "Date & Time: ")
                            }
                        }
                        .padding()
                    }
                    
                    // Fixed TextField at the bottom
                    if !historyViewModel.tasks.isEmpty {
 
                        HStack {
                            TextField("Enter email", text: $enteredEmail)
                                .padding()
                                .background(Color.white.opacity(0.7))
                                .cornerRadius(8)
                                .overlay(
                                    HStack {
                                        Spacer()
                                        Button(action: {
                                            // Action for the button
                                            print("Sent email: \(enteredEmail)")
                                            
                                        }) {
                                            Image(systemName: !enteredEmail.isEmpty ? "paperplane.fill" : "paperplane")
                                                .foregroundColor(.blue)
                                        }
                                    }
                                        .padding(.trailing, 15),
                                    alignment: .trailing
                                )
                        }
                        .padding()
                    }
                   
                }
                .navigationTitle("History")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Button("Sign Out", action: historyViewModel.signOut)
                            Button("Delete Account", action: {
                                historyViewModel.deleteAccount()
                            })
                        } label: {
                            Label("Options", systemImage: "ellipsis.circle")
                        }
                    }
                }
                .background(Color(red: 105/255, green: 155/255, blue: 157/255).ignoresSafeArea())
            }
            .onAppear {
                historyViewModel.fetchTasks()
            }
            
            // Overlay the "Something Went Wrong" card
            if showSomethingWentWrong {
                SomethingWentWrongView(retryAction: {
                    if networkMonitor.isConnected {
                        showSomethingWentWrong = false
                    } else {
                        print("Network is still down!")
                    }
                })
                .transition(.scale)
            }
        }
        .animation(.easeInOut, value: showSomethingWentWrong)
        .onReceive(networkMonitor.$isConnected) { isConnected in
            print("Network status changed: \(isConnected)")
            showSomethingWentWrong = !isConnected
        }
    }
}



struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
        
    }
}

