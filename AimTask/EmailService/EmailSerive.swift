//
//  EmailSerive.swift
//  AimTask
//
//  Created by Vilayath Mohammed on 6/9/2024.
//

import Foundation

class EmailService: ObservableObject {
    var locationNames: [String]
    var dateTimes: [String]
    var completedTasks: [String]
    var historyViewModel: HistoryViewModel?
    @Published var emailErrorMessage: String = ""
    @Published var isPositive: Bool = false
    
    init(locationNames: [String], dateTimes: [String], completedTasks: [String], historyViewModel: HistoryViewModel? = nil) {
        self.locationNames = locationNames
        self.dateTimes = dateTimes
        self.completedTasks = completedTasks
        self.historyViewModel = historyViewModel
    }
    
    func formatEmailBody() -> String {
        var htmlContent = "<h3>This email is from AIMTASK app completed task summary and it's details</h3>"
        
        for (index, location) in locationNames.enumerated() {
            let dateTime = index < dateTimes.count ? dateTimes[index] : "N/A"
            let completedTask = index < completedTasks.count ? completedTasks[index] : "No completed tasks"
            
            htmlContent += """
                <p><strong>Location 📍:</strong>\(location)</p>
                <p><strong>Date & Time ⏱️:</strong>\(dateTime)</p>
                <p><strong>Completed Tasks ✅:</strong>\(completedTask)</p>
                <hr>
            """
        }
        
        return htmlContent
    }

    func sendEmail(emailAddress: String) {
        let apiKeyRaw = AppConfig.shared.secretApiEmailPublicKey
        let refinedApiKey = apiKeyRaw.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
        
        let secretKeyRaw = AppConfig.shared.secretApiEmailPrivateKey
        let refinedSecretKey = secretKeyRaw.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
        let mailJetURL = URL(string: "https://api.mailjet.com/v3.1/send")!
        
        var request = URLRequest(url: mailJetURL)
        request.httpMethod = "POST"
        
        let authString = "\(refinedApiKey):\(refinedSecretKey)"
        let authData = authString.data(using: .utf8)!
        let base64AuthString = authData.base64EncodedString()
        
        request.addValue("Basic \(base64AuthString)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let emailBody = formatEmailBody()
        
        let emailData: [String: Any] = [
            "Messages": [
                [
                    "From": ["Email": "vilayathussain290@gmail.com", "Name": "AimTask"],
                    "To": [["Email": "\(emailAddress)", "Name": "Vilayath"]],
                    "Subject": "Task Summary from AimTask",
                    "TextPart": "Here is your task summary.",
                    "HTMLPart": emailBody
                ]
            ]
        ]
        
        request.httpBody = try! JSONSerialization.data(withJSONObject: emailData, options: [])
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data in response")
                return
            }

            let responseString = String(data: data, encoding: .utf8)!
            print("Response: \(responseString)")
            if responseString.contains("success") {
                self.updateHistoryViewModel(errorMessage: "Email delivered successfully 👍🏻 🎉", isPositive: true)
            } else if responseString.contains("error") {
                self.updateHistoryViewModel(errorMessage: "Something is not right!", isPositive: false)
            }
        }
        
        task.resume()
    }
    
    private func updateHistoryViewModel(errorMessage: String, isPositive: Bool) {
           DispatchQueue.main.async {
               self.historyViewModel?.errorMessage = errorMessage
               self.historyViewModel?.isPositive = isPositive
           }
       }
}
