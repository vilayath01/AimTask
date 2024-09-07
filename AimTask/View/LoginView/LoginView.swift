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
                Spacer().frame(height: 100) // Adjust the spacing as needed

                Text(loginViewModel.flow == .signUp ? "Welcome" : "Login")
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom, 40)

                VStack(spacing: 20) {
                    // Email field
                    TextField("Email", text: $loginViewModel.refineEmail)
                        .keyboardType(.emailAddress)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(5)
                        .foregroundColor(.white)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.white))

                    // Password field
                    HStack{
                        if isPasswordVisible {
                            TextField("Password", text: $loginViewModel.refinePassword)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(5)
                                .foregroundColor(.white)
                                .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.white))
                        } else {
                            SecureField("Password", text: $loginViewModel.refinePassword)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(5)
                                .foregroundColor(.white)
                                .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.white))
                        }
                        
                        Button(action: {
                            isPasswordVisible.toggle()
                        }) {
                            Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                                .foregroundColor(.white)
                        }
                        .padding(.trailing, 10)
                    }
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.white))
                   
                    
                    
                    if loginViewModel.flow == .signUp {
                        HStack {
                            if isConfirmPasswordVisible {
                                TextField("Confirm Password", text: $loginViewModel.confirmPassword)
                                    .padding()
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(5)
                                    .foregroundColor(.white)
                                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.white))
                            } else {
                                SecureField("Confirm Password", text: $loginViewModel.confirmPassword)
                                    .padding()
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(5)
                                    .foregroundColor(.white)
                                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.white))
                            }
                            Button(action: {
                                isConfirmPasswordVisible.toggle()
                            }) {
                                Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                                    .foregroundColor(.white)
                            }
                            .padding(.trailing, 10)
                        }
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.white))
                      
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
                    Text(loginViewModel.flow == .signUp ? "Sign up" : "Login")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
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
                    Text(loginViewModel.flow == .signUp ? "Already have an account?" : "Want to create an account?")
                        .foregroundColor(.white)
                    Button(action: {
                        loginViewModel.switchFlow()
                    }) {
                        Text(loginViewModel.flow == .signUp ? "Login" : "Sign up")
                            .foregroundColor(.red)
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

