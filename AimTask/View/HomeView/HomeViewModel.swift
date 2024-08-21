//
//  HomeViewModel.swift
//  AimTask
//
//  Created by Vilayath Mohammed on 21/8/2024.
//

import Foundation
import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var tasks: [TaskModel] = []
    @Published var completedItems: Set<String> = []
    private var fdbManager: FDBManager
    
    init(fdbManager: FDBManager = FDBManager()) {
        self.fdbManager = fdbManager
        self.fdbManager.$tasks
            .receive(on: DispatchQueue.main)
            .assign(to: &$tasks)
        fetchTasks()
    }
    
    func fetchTasks() {
        fdbManager.fetchTasks()
    }
    
    func toggleItemCompletion(_ item: String) {
        if completedItems.contains(item) {
            completedItems.remove(item)
        } else {
            completedItems.insert(item)
        }
    }
    
    func deleteTask(from documentID: String, item: String) {
        fdbManager.deleteTask(from: documentID, item: item)
    }
    
    func deleteWholeDoc(_ documentId: [String]) {
        
        fdbManager.deleteDocument(with: documentId)
    }
    
}

