//
//  EmailSerive.swift
//  AimTask
//
//  Created by Vilayath Mohammed on 6/9/2024.
//

import Foundation


class EmailSerive {
    
    func sendEmail() {
        let apiKey = "911f773145b6ff6c1de8d26e67eecf92"
        let secretKey = "39256f7beabf58cfc1180a5d21db199c"
        let mailJetURL = URL(string: "https://api.mailjet.com/v3.1/send")!
        
        var request = URLRequest(url: mailJetURL)
        request.httpMethod = "POST"
        
        let authString = "\(apiKey):\(secretKey)"
        let authData = authString.data(using: .utf8)!
        let base64AuthString = authData.base64EncodedString()
        
        request.addValue("Basic \(base64AuthString)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let emailData: [String: Any] = [
            "Messages": [
                [
                    "From": ["Email": "vilayathussain290@gmail.com", "Name": "AimTask"],
                    "To": [["Email": "vilayath01@gmail.com", "Name": "Vilayath"]],
                    "Subject": "Text Email from Mailjet",
                    "TextPart": "Hello! This is a test email.",
                    "HTMLPart": "<h3>Dear vilayath, Welcome to mailJet email services!<h3>"
                ]
            ]
        ]
        
        request.httpBody = try! JSONSerialization.data(withJSONObject: emailData, options: [])
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            guard let data = data else {return}
            print("Response: \(String(data: data, encoding: .utf8)!)")
            
        }
        
        task.resume()
        
    }
}
