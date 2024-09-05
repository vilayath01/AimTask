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
        
        fdbManager.deleteTask(from: documentID, item: item)
    }
    
    func deleteWholeDoc(_ documentId: [String]) {
        
        fdbManager.deleteDocument(with: documentId)
    }
    
    func addTaskItem(from documentID: String, item: String) {
        
        fdbManager.addTaskItem(from: documentID, item: item)
    }
    
    func isGeofenceEntered(task: TaskModel) -> Bool {
        
        return task.enteredGeofence
    }
    
    func saveHistory(docId: String, isSave: Bool) {
        fdbManager.updateSaveHistory(for: docId, to: isSave)
    }
}
