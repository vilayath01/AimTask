//
//  loginScreen.swift
//  AimTask
//
//  Created by Vilayath Mohammed on 8/8/2024.
//

import SwiftUI

struct LoginView: View {
    
    @State private var isPasswordVisible: Bool = false
    @State private var isConfirmPasswordVisible: Bool = false
    @State private var emailContainsSpecialCharecter: Bool = false
    @State private var isEmptyField: Bool = false
    
    
    @EnvironmentObject var loginViewModel: LoginViewModel
    @Environment(\.dismiss) var dismiss
    
    private func areFieldsFilled() -> Bool {
        return !loginViewModel.refinePassword.isEmpty && !loginViewModel.confirmPassword.isEmpty && !loginViewModel.refineEmail.isEmpty
    }
    
    private func resetErrorFlags() {
        isEmptyField = false
        emailContainsSpecialCharecter = false
    }
    
    private func signInWithEmailPassword() {
        Task {
            if await loginViewModel.signInWithEmailPassword() == true {
                dismiss()
            }
        }
    }
    
    private func errorMessageView(_ message: String) -> some View {
        HStack {
            Text(message)
                .foregroundColor(.white)
                .padding()
                .background(Color.red.opacity(0.8))
                .cornerRadius(8)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 5)
    }
    
    var body: some View {
        ZStack {
            // Background color
            Color.black.ignoresSafeArea()
            
            // Diagonal red shape
            GeometryReader { geometry in
                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: width, y: 0))
                    path.addLine(to: CGPoint(x: width, y: height * 0.4))
                    path.addLine(to: CGPoint(x: 0, y: height * 0.7))
                    path.closeSubpath()
                }
                .fill(Color(red: 105/255, green: 155/255, blue: 157/255))
            }
            
            VStack {
                Spacer().frame(height: 100)
                
                styledText(
                    loginViewModel.flow == .signUp
                    ? LoginSingup.welcome.localized
                    : LoginSingup.login.localized,
                    fontSize: 28, textColor: .white
                )
                .padding(.bottom, 40)
                
                VStack(spacing: 20) {
                    // Email field
                    TextField(LoginSingup.email.localized, text: $loginViewModel.refineEmail)
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
                    
                    // Password field
                    HStack{
                        if isPasswordVisible {
                            TextField(LoginSingup.password.localized, text: $loginViewModel.refinePassword)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding(.leading, 4)
                                .font(.custom("Avenir", size: 16))
                                .bold()
                                .textInputAutocapitalization(.never)
                                .disableAutocorrection(true)
                            
                        } else {
                            SecureField(LoginSingup.password.localized, text: $loginViewModel.refinePassword)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding(.leading, 4)
                                .font(.custom("Avenir", size: 16))
                                .bold()
                                
                               
                        }
                        
                        Button(action: {
                            isPasswordVisible.toggle()
                        }) {
                            Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .padding(.leading, 4)
                                .font(.custom("Avenir", size: 16))
                                .bold()
                                .foregroundColor(Color(.systemGray))
                                
                               
                               
                        }
                        .padding(.trailing, 10)
                    }
                    
                    
                    
                    
                    if loginViewModel.flow == .signUp {
                        HStack {
                            if isConfirmPasswordVisible {
                                TextField(LoginSingup.confirmPassword.localized, text: $loginViewModel.confirmPassword)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .padding(.leading, 4)
                                    .font(.custom("Avenir", size: 16))
                                    .bold()
                                   
                            } else {
                                SecureField(LoginSingup.confirmPassword.localized, text: $loginViewModel.confirmPassword)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .padding(.leading, 4)
                                    .font(.custom("Avenir", size: 16))
                                    .bold()
                            }
                            Button(action: {
                                isConfirmPasswordVisible.toggle()
                            }) {
                                Image(systemName: isConfirmPasswordVisible ? "eye" : "eye.slash")
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                    .padding(.leading, 4)
                                    .font(.custom("Avenir", size: 16))
                                    .bold()
                                    .foregroundColor(Color(.systemGray))
                            }
                            .padding(.trailing, 10)
                        }
                       
                        
                    }
                }
                .padding(.horizontal, 40)
                
                Button(action: {
                    if loginViewModel.flow == .signUp {
                        loginViewModel.signUp(email: loginViewModel.refineEmail, password: loginViewModel.refinePassword, confirmPassword: loginViewModel.confirmPassword)
                    } else {
                        loginViewModel.login(email: loginViewModel.refineEmail, password: loginViewModel.refinePassword)
                    }
                }) {
                    styledText(loginViewModel.flow == .signUp ? LoginSingup.signUp.localized : LoginSingup.login.localized, fontSize: 20, textColor: .white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 40)
                
                
                VStack {
                    if !loginViewModel.errorMessage.isEmpty {
                        errorMessageView(loginViewModel.errorMessage)
                    }
                }
                
                Spacer()
                
                HStack {
                    styledText(loginViewModel.flow == .signUp ? LoginSingup.haveAccountDescription.localized : LoginSingup.wantAccountDescription.localized, fontSize: 18, textColor: .white)
                    Button(action: {
                        loginViewModel.switchFlow()
                    }) {
                        styledText(loginViewModel.flow == .signUp ? LoginSingup.login.localized : LoginSingup.signUp.localized, fontSize: 18, textColor: .red)
                    }
                }
                .padding(.bottom, 30)
            }
            if loginViewModel.isLoading {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(10)
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(LoginViewModel())
    }
}

