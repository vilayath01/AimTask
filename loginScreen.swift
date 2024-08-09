//
//  loginScreen.swift
//  AimTask
//
//  Created by Vilayath Mohammed on 8/8/2024.
//

import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var emailContainsSpecialCharecter: Bool = false
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isSignUp: Bool = true
    @State private var isPasswordVisible: Bool = false
    @State private var isConfirmPasswordVisible: Bool = false
    @State private var isEmptyField: Bool = false
    @ObservedObject var loginViewModel = LoginViewModel()

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

                Text(isSignUp ? "Welcome" : "Login")
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom, 40)

                VStack(spacing: 20) {
                    // Email field
                    TextField("Email", text: $email)
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
                            TextField("Password", text: $password)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(5)
                                .foregroundColor(.white)
                                .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.white))
                        } else {
                            SecureField("Password", text: $password)
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
                   
                    
                    
                    if isSignUp {
                        HStack {
                            if isConfirmPasswordVisible {
                                TextField("Confirm Password", text: $confirmPassword)
                                    .padding()
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(5)
                                    .foregroundColor(.white)
                                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.white))
                            } else {
                                SecureField("Confirm Password", text: $confirmPassword)
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
                    if isSignUp {
                        
                        if password != "" && confirmPassword != "" && email != "" {
                            if !email.contains("@") {
                                emailContainsSpecialCharecter.toggle()
                            } else {
                                loginViewModel.checkPassword(password: password, confrimPassword: confirmPassword)
                                isEmptyField = false
                                emailContainsSpecialCharecter = false
                            }
                        
                        } else {
                            isEmptyField.toggle()
                        }
                  
                    } else {
                        // Handle Login
                    }
                    // Sign up action
                }) {
                    Text(isSignUp ? "Sign up" : "Login")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 40)
                
                if isEmptyField {
                    HStack {
                        Text ("Please enter all fields!")
                            .foregroundColor(.red)
                            .background(Color.white.opacity(0.2))
                    }
                } else {
                    
                }
                
               if  loginViewModel.isAlert {
                   HStack {
                       Text ("password not matching. Please try again!")
                           .foregroundColor(.red)
                           .background(Color.white.opacity(0.2))
                   }
               } else {
                   
               }
                
                if emailContainsSpecialCharecter {
                    HStack {
                        Text ("make sure your email has @")
                            .foregroundColor(.red)
                            .background(Color.white.opacity(0.2))
                    }
                } else {
                    
                }

                Spacer()

                // Toggle between SignUp and Login
                HStack {
                    Text(isSignUp ? "Already have an account?" : "Want to create an account?")
                        .foregroundColor(.white)
                    Button(action: {
                        // Navigate to login screen
                        isSignUp.toggle()
                    }) {
                        Text(isSignUp ? "Login" : "Sign up")
                            .foregroundColor(.red)
                    }
                }
                .padding(.bottom, 30)
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

