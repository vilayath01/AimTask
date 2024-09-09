//
//  historyViewModel.swift
//  AimTask
//
//  Created by vila on 2/9/2024.
//

import Foundation

class HistoryViewModel: ObservableObject {
    private var fdbManager: FDBManager
    @Published var loginViewModel: LoginViewModel
    @Published var tasks: [TaskModel] = []
    private var emailAddress: String = ""
    @Published var isPositive: Bool = false
    @Published var errorMessage: String = ""
    @Published var showDeleteAlert: Bool = false
    var emailSerive: EmailService?

    // Store selected task details
    @Published var selectedLocationNames: [String] = []
    @Published var selectedDateTimes: [String] = []
    @Published var selectedCompletedTasks: [String] = []

    init(loginViewModel: LoginViewModel, fdbManager: FDBManager = FDBManager()) {
        self.loginViewModel = loginViewModel
        self.fdbManager = fdbManager
        self.fdbManager.$tasks
            .receive(on: DispatchQueue.main)
            .assign(to: &$tasks)
        fetchTasks()
    }

    @MainActor func signOut() {
        loginViewModel.signOut()
    }

    func deleteAccount()  {
        
        showDeleteAlert = true
    }
    
    func confirmDeleteAccount() {
        
        if fdbManager.errorMessageFDB.isEmpty {
            fdbManager.delteAccount()
        } else {
            errorMessage = fdbManager.errorMessageFDB
        }
    }
    
    func fetchTasks() {
        
        fdbManager.fetchTasks()
    }
    
    func saveHistory(docId: String, isSave: Bool) {
        fdbManager.updateSaveHistory(for: docId, to: isSave)
    }
    
    func enteredEmailAddress(email: String) {
        if !selectedLocationNames.isEmpty {
            emailAddress = email
            let emailService = EmailService(locationNames: selectedLocationNames, dateTimes: selectedDateTimes, completedTasks: selectedCompletedTasks, historyViewModel: self)
            emailService.sendEmail(emailAddress: email)
            emailSentMessage()
        } else {
            print("Please choose task to send via email")
            self.isPositive = false
            self.errorMessage = "Please choose task to send via email"
        }
    }
    
    func selectTask(task: TaskModel) {
           selectedLocationNames.append(task.locationName)
           selectedDateTimes.append(task.dateTime.formatted())
           selectedCompletedTasks.append(task.taskItems.joined(separator: ", "))
       }

     func clearSelectedTask(task: TaskModel) {
         if let index = selectedLocationNames.firstIndex(of: task.locationName) {
             selectedLocationNames.remove(at: index)
             selectedDateTimes.remove(at: index)
             selectedCompletedTasks.remove(at: index)
         }
     }
    
    func emailSentMessage() {
        errorMessage = emailSerive?.emailErrorMessage ?? ""
        isPositive = ((emailSerive?.isPositive) != nil)
    }
}

