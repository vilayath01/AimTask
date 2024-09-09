//
//  HomeViewModel.swift
//  AimTask
//
//  Created by Vilayath Mohammed on 21/8/2024.
//

import Foundation
import SwiftUI
import CoreLocation

class HomeViewModel: ObservableObject {
    
    @Published var tasks: [TaskModel] = []
    private var fdbManager: FDBManager
    @Published var isPositive: Bool = false
    @Published var errorMessage: String = ""
    
    init(fdbManager: FDBManager = FDBManager()) {
        
        self.fdbManager = fdbManager
        self.fdbManager.$tasks
            .receive(on: DispatchQueue.main)
            .assign(to: &$tasks)
        fetchTasks()
        LocalNotifications.shared.requestNotificationPermission()
    }
    
    func fetchTasks() {
        
        fdbManager.fetchTasks()
    }
    
    
    func deleteTask(from documentID: String, item: String) {
        
        if fdbManager.errorMessageFDB.isEmpty {
            fdbManager.deleteTask(from: documentID, item: item)
        } else {
            errorMessage = fdbManager.errorMessageFDB
        }
    }
    
    func deleteWholeDoc(_ documentId: [String], locationName: String, isPositive: Bool) {
        
        if fdbManager.errorMessageFDB.isEmpty {
            fdbManager.deleteDocument(with: documentId)
            
            DispatchQueue.main.async {
                self.errorMessage = "Your \(locationName) task has been deleted."
                self.isPositive = isPositive
                
                print("This is errorMessage: \(self.errorMessage)")
            }
        } else {
            errorMessage = fdbManager.errorMessageFDB
        }
    }
    
    func addTaskItem(from documentID: String, item: String) {
        if fdbManager.errorMessageFDB.isEmpty {
            fdbManager.addTaskItem(from: documentID, item: item)
        } else {
            errorMessage = fdbManager.errorMessageFDB
        }
    }
    
    func isGeofenceEntered(task: TaskModel) -> Bool {
        
        return task.enteredGeofence
    }
    
    func saveHistory(docId: String, isSave: Bool, locationName: String, isPositive: Bool) {
        fdbManager.updateSaveHistory(for: docId, to: isSave)
        
        DispatchQueue.main.async {
            self.errorMessage = "Your \(locationName) task has been saved in history."
            self.isPositive = isPositive
            
            print("This is errorMessage: \(self.errorMessage)")
        }
    }
}
