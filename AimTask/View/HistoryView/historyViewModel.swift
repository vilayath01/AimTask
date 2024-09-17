//
//  historyViewModel.swift
//  AimTask
//
//  Created by vila on 2/9/2024.
//

import Foundation

enum HistoryViewString {
    static let title = "title_history"
    static let locationName = "location_name"
    static let addTaskDateTime = "add_task_date_time"
    static let completedTaskDateTime = "completed_task_date_time"
    static let enterEmailPlaceholder = "enter_email_placeholder"
    static let validEmailError = "error_valid_email"
    static let signOut = "sign_out"
    static let deleteAccount = "delete_account"
    static let alertTitle = "alert_title"
    static let alertDescription = "alert_description"
    static let okay =  "okay"
    static let chooseTaskError = "error_choose_task"
    
    static func localized(_ key: String, _ arguments: CVarArg...) -> String {
        let formatString = NSLocalizedString(key, comment: "")
        return String(format: formatString, arguments: arguments)
    }
}

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
    @Published var selectedaddDateTimes: [String] = []
    @Published var selectedCompletedDateTimes: [String] = []
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
            isPositive = false
        }
    }
    
    func fetchTasks() {
        
        fdbManager.fetchTasks()
    }
    
    func saveHistory(docId: String, isSave: Bool) {
        fdbManager.updateSaveHistory(for: docId, to: isSave)
    }
    
    @MainActor func enteredEmailAddress(email: String) {
        if !selectedLocationNames.isEmpty {
            emailAddress = email
            let emailService = EmailService(locationNames: selectedLocationNames,taskAddedDateTime: selectedaddDateTimes, taskCompletedDateTime: selectedCompletedDateTimes,completedTasks: selectedCompletedTasks, historyViewModel: self, userName:loginViewModel.displayName )
            emailService.sendEmail(emailAddress: email)
            emailSentMessage()
        } else {
            self.isPositive = false
            self.errorMessage = HistoryViewString.chooseTaskError.localized
        }
    }
    
    func selectTask(task: TaskModel) {
        selectedLocationNames.append(task.locationName)
        selectedaddDateTimes.append(task.addTaskDateTime.formatted())
        selectedCompletedDateTimes.append(task.completedTaskDateTime.formatted())
        selectedCompletedTasks.append(task.taskItems.joined(separator: ", "))
    }
    
    func clearSelectedTask(task: TaskModel) {
        if let index = selectedLocationNames.firstIndex(of: task.locationName) {
            selectedLocationNames.remove(at: index)
            selectedaddDateTimes.remove(at: index)
            selectedCompletedDateTimes.remove(at: index)
            selectedCompletedTasks.remove(at: index)
        }
    }
    
    func emailSentMessage() {
        errorMessage = emailSerive?.emailErrorMessage ?? ""
        isPositive = ((emailSerive?.isPositive) != nil)
    }
}

