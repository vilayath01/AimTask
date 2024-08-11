//
//  LoginViewModel.swift
//  AimTask
//
//  Created by Vilayath Mohammed on 8/8/2024.
//

import Foundation
import FirebaseAuth
import AuthenticationServices

enum AuthenticationState {
    case unauthenticated
    case authenticating
    case authenticated
}

enum AuthenticationFlow {
    case login
    case signUp
}

enum LogInOrSignUpError: Error {
    case invalidEmail
    case passwordMismatch
    case emptyFields
    case custom(String) // For custom error messages
}

@MainActor
class LoginViewModel: ObservableObject {
    
    @Published var isLoggin: Bool = false
    @Published var isAlert: Bool = false
    @Published var refinePassword: String = ""
    @Published var confirmPassword: String = ""
    @Published var refineEmail: String = ""
    @Published var errorMessage: String = ""
    @Published var user: User?
    @Published var flow: AuthenticationFlow = .login
    @Published var authenticationState: AuthenticationState = .unauthenticated
    @Published var isLoading: Bool = false
    
    init() {
        registerAuthStateHandler()
    }
    
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    
    func registerAuthStateHandler() {
        if authStateHandler == nil {
            authStateHandler = Auth.auth().addStateDidChangeListener { auth, user in
                self.user = user
                self.authenticationState = user == nil ? .unauthenticated : .authenticated
            }
        }
    }
    
    func validateSignUp(email: String, password: String, confirmPassword: String) -> LogInOrSignUpError? {
        if email.isEmpty || password.isEmpty || confirmPassword.isEmpty {
            return .emptyFields
        } else if !email.contains("@") {
            return .invalidEmail
        } else if password != confirmPassword {
            return .passwordMismatch
        }
        return nil
    }
    
    func validateLogin(email: String, password: String) -> LogInOrSignUpError? {
        if email.isEmpty || password.isEmpty {
            return .emptyFields
        } else if !email.contains("@") {
            return .invalidEmail
        }
        return nil
    }
    
    func setErrorMessage(for error: LogInOrSignUpError) {
        switch error {
        case .invalidEmail:
            errorMessage = "Looks like invalid Email..!"
        case .passwordMismatch:
            errorMessage = "Password do not match!"
        case .emptyFields:
            errorMessage = "please fill in all the fields."
        case .custom(let message):
            errorMessage = message
        }
    }
    
    func signUp(email: String, password: String, confirmPassword: String) {
        self.isLoading = true
        defer { self.isLoading = false }
        if let error = validateSignUp(email: email, password: password, confirmPassword: confirmPassword) {
            setErrorMessage(for: error)
            return
        }
        
        Task {
            if await signUpWithEmailPassword() == true {
                self.flow = .signUp
                self.authenticationState = .authenticated
                resetAndSwitch()
            } else {
                self.authenticationState = .unauthenticated
            }
        }
    }
    
    func login(email: String, password: String) {
        self.isLoading = true
        defer { self.isLoading = false }
        
        if let error = validateLogin(email: email, password: password) {
            setErrorMessage(for: error)
            
            return
        }
        
        Task {
            if await signInWithEmailPassword() == true {
                self.authenticationState = .authenticated
                resetAndSwitch()
            } else {
                self.authenticationState = .unauthenticated
            }
        }
    }
}


extension LoginViewModel {
    func signInWithEmailPassword() async -> Bool {
        authenticationState = .authenticating
        self.isLoading = true
        do {
            try await Auth.auth().signIn(withEmail: self.refineEmail, password: self.refinePassword)
            
            authenticationState = .authenticated
            self.isLoading = false
            return true
        }
        catch let authError as NSError {
            handleError(authError)
            self.isLoading = false
            return false
        }
    }
    
    func signUpWithEmailPassword() async -> Bool {
        authenticationState = .authenticating
        self.isLoading = true
        do  {
            try await Auth.auth().createUser(withEmail: refineEmail, password: refinePassword)
            self.isLoading = false
            return true
        }
        catch let authError as NSError {
            handleError(authError)
            self.isLoading = false
            return false
        }
    }
    
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            authenticationState = .unauthenticated
        }
        catch {
            errorMessage = error.localizedDescription
            isAlert = true
        }
    }
    
    func deleteAccount() async -> Bool {
        do {
            try await user?.delete()
            authenticationState = .unauthenticated
            return true
        }
        catch {
            errorMessage = error.localizedDescription
            isAlert = true
            return false
        }
    }
    
    func switchFlow() {
        flow = flow == .login ? .signUp : .login
        errorMessage = ""
    }
    
    func resetAndSwitch() {
        flow = .login
        refineEmail  = ""
        refinePassword = ""
        confirmPassword = ""
        errorMessage = ""
    }
    
    
    // Error Handling From Here
    
    private func handleError(_ error: NSError) {
        switch error.code {
        case AuthErrorCode.invalidCredential.rawValue:
            errorMessage = "The supplied auth credential is malformed or has expired."
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            errorMessage = "The email address is already in use."
        case AuthErrorCode.weakPassword.rawValue:
            errorMessage = "The password is too weak."
            // Add more cases as needed
        default:
            errorMessage = "An unknown error occurred. Please try again."
        }
        authenticationState = .unauthenticated
        isAlert = true
    }
}
