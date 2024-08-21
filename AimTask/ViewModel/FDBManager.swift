//
//  ViewModel.swift
//  AimTask
//
//  Created by Vilayath Mohammed on 21/7/2024.
//

import Foundation
import Firebase
import Combine
import CoreLocation

class FDBManager: ObservableObject {
    @Published var tasks = [TaskModel]()
    private let db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    func fetchTasks()  {
        print("This is userEmail:\(Auth.auth().currentUser)")
        guard let user = Auth.auth().currentUser
                
        else {
            print("No authenticated user found")
            return
        }
        
        Future<[TaskModel], Error> { promise in
            self.db.collection("users").document(user.uid).collection("tasks").getDocuments { querySnapshot, error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    let tasks = querySnapshot?.documents.compactMap({ doc -> TaskModel? in
                        let data = doc.data()
                        guard
                            let locationName = data["locationName"] as? String,
                            let taskItems = data["taskItems"] as? [String],
                            let dateTime = (data["dateTime"] as? Timestamp)?.dateValue(),
                            let coordinateData = data["coordinate"] as? [String: Double],
                            let latitude = coordinateData["latitude"],
                            let longitude = coordinateData["longitude"]
                        else {
                            return nil
                        }
                        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                        return TaskModel(locationName: locationName, dateTime: dateTime, taskItems: taskItems, coordinate: location, documentID: doc.documentID)
                    }) ?? []
                    promise(.success(tasks))
                }
            }
        }
        .replaceError(with: [])
        .receive(on: DispatchQueue.main)
        .assign(to: \.tasks, on: self)
        .store(in: &cancellables)
        
    }
    
    func addTask(_ task: TaskModel) {
        guard let user = Auth.auth().currentUser else {
            print("No Authenticated user found")
            return
        }
        
        let coordinateData: [String: Any] = [
            "latitude": task.coordinate.latitude,
            "longitude": task.coordinate.longitude
        ]
        let newTaskItems = task.taskItems
        let data: [String: Any] = [
            "dateTime" : Timestamp(date: task.dateTime),
            "taskItems" : task.taskItems,
            "locationName": task.locationName,
            "coordinate" : coordinateData
        ]
        
        let userTasksCollection = self.db.collection("users").document(user.uid).collection("tasks")
        
        // Check for existing task with the same location name
        Future<Void, Error> { promise in
            userTasksCollection
                .whereField("locationName", isEqualTo: task.locationName)
                .getDocuments { (querySnapshot, error) in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    
                    if let querySnapshot = querySnapshot, !querySnapshot.isEmpty {
                        // If task with the same location name exists, update it
                        if let document = querySnapshot.documents.first, var existingTaskItems = document.data()["taskItems"] as? [String] {
                            existingTaskItems.append(contentsOf: newTaskItems)
                            
                            document.reference.updateData([
                                "taskItems": existingTaskItems,
                                "dateTime": Timestamp(date: task.dateTime)
                            ]) { error in
                                if let error = error {
                                    promise(.failure(error))
                                } else {
                                    promise(.success(()))
                                }
                            }
                        }
                    } else {
                        // If no duplicates found, add the new task
                        var updateData = data
                        updateData["taskItems"] = newTaskItems
                        
                        userTasksCollection.addDocument(data: updateData) { error in
                            if let error = error {
                                promise(.failure(error))
                            } else {
                                promise(.success(()))
                            }
                        }
                    }
                }
        }
        .sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                print("Error occurred: \(error)")
            case .finished:
                print("Operation completed successfully")
            }
        }, receiveValue: { _ in
            self.fetchTasks()
        })
        .store(in: &self.cancellables)
    }
    
    func deleteDocument(with documentIDs: [String]) {
        guard let user = Auth.auth().currentUser else {
            print("No authenticated user found")
            return
        }
        
        // Reference to the task document using the provided documentID
        let userTaskCollection = db.collection("users").document(user.uid).collection("tasks")
        
        // Perform the deletion
        let deleteFutures: [Future<Void, Error>] = documentIDs.map { documentID in
            Future<Void, Error> { promise in
                userTaskCollection.document(documentID).delete { error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        promise(.success(()))
                    }
                }
            }
        }
        
        Publishers.MergeMany(deleteFutures)
            .collect()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Failed to delete task: \(error.localizedDescription)")
                case .finished:
                    print("Task deleted successfully")
                }
            }, receiveValue: { _ in
                // Refresh the tasks after deletion
                self.fetchTasks()
            })
            .store(in: &self.cancellables)
    }
    
    func deleteTask(from documentID: String, item: String) {
        guard let user = Auth.auth().currentUser else {
            print("No authenticated user found")
            return
        }
        
        // Reference to the specific task document using the provided documentID
        let userTasksCollection = db.collection("users").document(user.uid).collection("tasks")
        
        Future<Void, Error> { promise in
            userTasksCollection.document(documentID).getDocument { documentSnapshot, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                
                guard let document = documentSnapshot, document.exists,
                      var taskItems = document.data()?["taskItems"] as? [String] else {
                    promise(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Document does not exist or taskItems field is missing"])))
                    return
                }
                
                // Remove the specific item from the array
                if let index = taskItems.firstIndex(of: item) {
                    taskItems.remove(at: index)
                    
                    // Update the document with the modified array
                    userTasksCollection.document(documentID).updateData(["taskItems": taskItems]) { error in
                        if let error = error {
                            promise(.failure(error))
                        } else {
                            promise(.success(()))
                        }
                    }
                } else {
                    promise(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Item not found in taskItems"])))
                }
            }
        }
        .sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                print("Failed to delete task item: \(error.localizedDescription)")
            case .finished:
                print("Task item deleted successfully")
            }
        }, receiveValue: { _ in
            // Refresh the tasks after deletion
            self.fetchTasks()
        })
        .store(in: &self.cancellables)
    }
}
