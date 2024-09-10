//
//  HomeView.swift
//  AimTask
//
//  Created by Vilayath Mohammed on 22/7/2024.
//

import SwiftUI

struct HistoryView: View {
    @StateObject var historyViewModel = HistoryViewModel(loginViewModel: LoginViewModel())
    @StateObject private var networkMonitor = NetworkMonitor()
    @State private var showSomethingWentWrong = false
    @State private var enteredEmail: String = ""
    
    var body: some View {
        ZStack {
            NavigationView {
                VStack {
                    if !historyViewModel.errorMessage.isEmpty {
                        ErrorBarView(errorMessage: $historyViewModel.errorMessage, isPositive: $historyViewModel.isPositive)
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .animation(.easeInOut, value: historyViewModel.errorMessage)
                    }
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            
                            if !historyViewModel.tasks.contains(where: {$0.saveHistory}) {
                                NoTasksView(taskViewToShow: false)
                                    .frame(maxHeight: .infinity)
                            } else {
                                ForEach (historyViewModel.tasks.filter{$0.saveHistory}, id: \.documentID){ task in
                                    HistoryTaskSection(
                                        viewModel: historyViewModel,
                                        task: task,
                                        title: HistoryViewString.localized(HistoryViewString.locationName.localized, task.locationName),
                                        subtitle: HistoryViewString.localized(HistoryViewString.dateTime.localized, task.dateTime.formatted())
                                    )
                                }
                            }
                        }
                        .padding()
                    }
                    
                    if historyViewModel.tasks.contains(where: {$0.saveHistory}) {
                        
                        HStack {
                            TextField(HistoryViewString.enterEmailPlaceholder.localized, text: $enteredEmail)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .font(.custom("Avenir", size: 16))
                                .overlay(
                                    HStack {
                                        Spacer()
                                        Button(action: {
                                            
                                            if (enteredEmail.contains("@")) {
                                                historyViewModel.enteredEmailAddress(email: enteredEmail)
                                                enteredEmail = ""
                                            } else {
                                                historyViewModel.errorMessage = HistoryViewString.validEmailError.localized
                                            }
                                            
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
                .navigationTitle(HistoryViewString.title.localized)
                
                
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Button(HistoryViewString.signOut.localized, action: historyViewModel.signOut)
                            Button(HistoryViewString.deleteAccount.localized, action: {
                                historyViewModel.deleteAccount()
                                
                            })
                        } label: {
                            VStack {
                                Image(systemName: "gear")
                                    .font(.headline)
                                    .bold()
                                    .foregroundColor(.black)
                                    .padding(.trailing)
                                
                                styledText("Setting",fontSize: 14, textColor: .black)
                                    .padding(.trailing)
                            }
                        }
                    }
                }
                .background(Color(red: 105/255, green: 155/255, blue: 157/255).ignoresSafeArea())
                .alert(isPresented: $historyViewModel.showDeleteAlert, content: {
                    Alert(title: Text(HistoryViewString.alertTitle.localized), message: Text(HistoryViewString.alertDescription.localized), primaryButton: .destructive(Text(HistoryViewString.okay.localized), action: {
                        historyViewModel.confirmDeleteAccount()
                    }), secondaryButton: .cancel())
                })
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

