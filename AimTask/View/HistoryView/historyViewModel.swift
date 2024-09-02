//
//  historyViewModel.swift
//  AimTask
//
//  Created by vila on 2/9/2024.
//

import Foundation

class HistoryViewModel: ObservableObject {
    @Published var loginViewModel: LoginViewModel

    init(loginViewModel: LoginViewModel) {
        self.loginViewModel = loginViewModel
    }

    @MainActor func signOut() {
        loginViewModel.signOut()
    }

    func deleteAccount() async {
        await loginViewModel.deleteAccount()
    }
}

