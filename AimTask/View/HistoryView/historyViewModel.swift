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
        
        fdbManager.delteAccount()
    }
    
    func fetchTasks() {
        
        fdbManager.fetchTasks()
    }
}

