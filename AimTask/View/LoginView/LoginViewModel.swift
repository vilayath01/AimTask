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
    case custom(String)
}

enum LoginSingup {
    static let welcome = "welcome"
    static let login = "login"
    static let signUp = "signUp"
    static let email = "email"
    static let password = "password"
    static let confirmPassword = "confirm_password"
    static let haveAccountDescription = "have_account_description"
    static let wantAccountDescription = "want_account_description"
    static let invalidEmail = "invalid_email"
    static let passwordMismatch = "password_mismatch"
    static let emptyField = "empty_field"
    static let invalidCredential = "invalid_credential"
    static let emailAlreadyInUse = "email_already_in_use"
    static let weakPassword = "weak_password"
    static let unknownError = "unknown_error"
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
    @Published var displayName: String = ""
    
    init() {
        registerAuthStateHandler()
    }
    
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    
    func registerAuthStateHandler() {
        if authStateHandler == nil {
            authStateHandler = Auth.auth().addStateDidChangeListener { auth, user in
                self.user = user
                self.authenticationState = user == nil ? .unauthenticated : .authenticated
                self.displayName = user?.email  ?? "😉"
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
            errorMessage = LoginSingup.invalidEmail.localized
        case .passwordMismatch:
            errorMessage = LoginSingup.passwordMismatch.localized
        case .emptyFields:
            errorMessage = LoginSingup.emptyField.localized
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
        defer {self.isLoading = false}
        do {
            try await Auth.auth().signIn(withEmail: self.refineEmail, password: self.refinePassword)
            
            authenticationState = .authenticated
            return true
        }
        catch let authError as NSError {
            handleError(authError)
            authenticationState = .unauthenticated
            return false
        }
    }
    
    func signUpWithEmailPassword() async -> Bool {
        authenticationState = .authenticating
        self.isLoading = true
        defer {self.isLoading = false}
        do  {
            try await Auth.auth().createUser(withEmail: refineEmail, password: refinePassword)
            return true
        }
        catch let authError as NSError {
            handleError(authError)
            return false
        }
    }
    
    
    func signOut() {
        self.isLoading = true
        defer {self.isLoading = false}
        do {
            try Auth.auth().signOut()
            authenticationState = .unauthenticated
        }
        catch {
            errorMessage = error.localizedDescription
            isAlert = true
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
            errorMessage = LoginSingup.invalidCredential.localized
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            errorMessage = LoginSingup.emailAlreadyInUse.localized
        case AuthErrorCode.weakPassword.rawValue:
            errorMessage = LoginSingup.weakPassword.localized
            // Add more cases as needed
        default:
            errorMessage = LoginSingup.unknownError.localized
        }
        authenticationState = .unauthenticated
        isAlert = true
    }
}
