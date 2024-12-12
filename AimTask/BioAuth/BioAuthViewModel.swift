//
//  BioAuthViewModel.swift
//  AimTask
//
//  Created by vila on 13/12/2024.
//

import LocalAuthentication

class BioAuthViewModel: ObservableObject {
    @Published var userNameBioAuth: String = ""
    @Published var passwordBioAuth: String = ""
    func bioAuth() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate to access your saved credentials"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authError in
                DispatchQueue.main.async{
                    if success {
                        self.fetchSavedCredentials()
                        
                    } else {
                        print("Authentication failed: \(authError?.localizedDescription ?? "Unknown error")")
                    }
                }
                
            }
        } else {
            print("Biometric authentication not available: \(error?.localizedDescription ?? "Unknown error")")
        }
    }
    
    func fetchSavedCredentials() {
            if let credentials = KeychainHelper.shared.fetchCredentials() {
                userNameBioAuth = credentials.userName
                passwordBioAuth = credentials.password
            }
        }
    
   
}

