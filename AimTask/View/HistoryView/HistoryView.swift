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
    @StateObject private var loginViewModel = LoginViewModel()
    @State private var showSomethingWentWrong = false
    @State private var enteredEmail: String = ""
    @State private var showLoginView: Bool = false
    
    var body: some View {
        ZStack {
            Color.aimTaskBackground
                .ignoresSafeArea(.all)
            
            NavigationView { // Updated to NavigationStack for iOS 16+
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
                                ForEach(historyViewModel.tasks.filter{$0.saveHistory}, id: \.documentID) { task in
                                    HistoryTaskSection(
                                        viewModel: historyViewModel,
                                        task: task,
                                        title: HistoryViewString.localized(HistoryViewString.locationName.localized, task.locationName),
                                        addTaskDateTimeSubtitle: HistoryViewString.localized(HistoryViewString.addTaskDateTime.localized, task.addTaskDateTime.formatted()),
                                        completedTaskDateTimeSubtitle: HistoryViewString.localized(HistoryViewString.completedTaskDateTime.localized, task.completedTaskDateTime.formatted())
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
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding(.leading, 4)
                                .font(.custom("Avenir", size: 16))
                                .bold()
                                .textInputAutocapitalization(.never)
                                .disableAutocorrection(true)
                                .keyboardType(.emailAddress)
                                .overlay(
                                    HStack {
                                        Spacer()
                                        Button(action: {
                                            if enteredEmail.contains("@") {
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
                
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        VStack {
                            styledText("\(HistoryViewString.title.localized)")
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            if loginViewModel.authenticationState == .anonymous {
                                Button("Create Account") {
                                    showLoginView = true
                                }
                            } else {
                                Button(HistoryViewString.signOut.localized, action: historyViewModel.signOut)
                                Button(HistoryViewString.deleteAccount.localized, action: historyViewModel.deleteAccount)
                            }
                        } label: {
                            VStack {
                                Image(systemName: "gear")
                                    .font(.headline)
                                    .bold()
                                    .foregroundColor(.black)
                                    .padding(.trailing)
                                
                                styledText("Setting", fontSize: 14, textColor: .black)
                                    .padding(.trailing)
                            }
                        }
                    }
                }
                
                .background(Color.aimTaskBackground.ignoresSafeArea())
                .alert(isPresented: $historyViewModel.showDeleteAlert) {
                    Alert(
                        title: Text(HistoryViewString.alertTitle.localized),
                        message: Text(HistoryViewString.alertDescription.localized),
                        primaryButton: .destructive(Text(HistoryViewString.okay.localized), action: {
                            historyViewModel.confirmDeleteAccount()
                        }),
                        secondaryButton: .cancel()
                    )
                }
            }
            .onAppear {
                historyViewModel.fetchTasks()
            }
            
            .fullScreenCover(isPresented: $showLoginView) {
                LoginView()
            }
            
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
