//
//  LoginViewModel.swift
//  AimTask
//
//  Created by Vilayath Mohammed on 8/8/2024.
//

import Foundation


class LoginViewModel: ObservableObject {
    
    @Published var isLoggin: Bool = false
    @Published var isAlert: Bool = false
    
    func checkPassword(password: String, confrimPassword: String) {
       
        if password == confrimPassword {
            isLoggin.toggle()
            isAlert = false
           
        } else {
            isAlert.toggle()
         
        }
    }
}
