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
    @Published var errorMessageFDB: String = ""
    
    func fetchTasks()  {
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
                            let longitude = coordinateData["longitude"],
                            let enteredGeofence = data["enteredGeofence"] as? Bool,
                            let saveHistory = data["saveHistory"] as? Bool
                                
                        else {
                            return nil
                        }
                        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                        return TaskModel(locationName: locationName, dateTime: dateTime, taskItems: taskItems, coordinate: location, documentID: doc.documentID, enteredGeofence: enteredGeofence, saveHistory: saveHistory)
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
        
        let data: [String: Any] = [
            "dateTime": Timestamp(date: task.dateTime),
            "taskItems": task.taskItems,
            "locationName": task.locationName,
            "coordinate": coordinateData,
            "enteredGeofence": task.enteredGeofence,
            "saveHistory": task.saveHistory
        ]
        
        let userTasksCollection = self.db.collection("users").document(user.uid).collection("tasks")
        
        Future<Void, Error> { promise in
            userTasksCollection
                .whereField("locationName", isEqualTo: task.locationName)
                .getDocuments { (querySnapshot, error) in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    
                    if let querySnapshot = querySnapshot, !querySnapshot.isEmpty {
                        
                        self.errorMessageFDB = "Already geo exists"
                        promise(.success(()))
                    } else {
                        // If no duplicates found, add the new task
                        userTasksCollection.addDocument(data: data) { error in
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
                self.errorMessageFDB = "Something went wrong! Try again"
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
                    self.errorMessageFDB = "Something went wrong! Try again"
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
                self.errorMessageFDB = "Something went wrong! Try again"
            case .finished:
                print("Task item deleted successfully")
            }
        }, receiveValue: { _ in
            // Refresh the tasks after deletion
            self.fetchTasks()
        })
        .store(in: &self.cancellables)
    }
    
    func addTaskItem(from documentID: String, item: String) {
        guard let user = Auth.auth().currentUser else {
            print("No authenticated user found")
            return
        }
        
        let userTasksCollection = db.collection("users").document(user.uid).collection("tasks")
        
        userTasksCollection.document(documentID).getDocument { documentSnapshot, error in
            if let error = error {
                print("Failed to fetch document: \(error.localizedDescription)")
                return
            }
            
            guard let document = documentSnapshot, document.exists,
                  var taskItems = document.data()?["taskItems"] as? [String] else {
                print("Document does not exist or taskItems field is missing")
                return
            }
            
            taskItems.append(item)
            
            userTasksCollection.document(documentID).updateData(["taskItems": taskItems]) { error in
                if let error = error {
                    print("Failed to add task item: \(error.localizedDescription)")
                    self.errorMessageFDB = "Something went wrong! Try again"
                } else {
                    print("Task item added successfully")
                    self.fetchTasks()
                }
            }
        }
    }
    
    //MARK:- update geofence entry and exit
    
    func updateEnteredGeofence(for documentID: String, to value: Bool) {
        guard let user = Auth.auth().currentUser else {
            print("No authenticated user found")
            return
        }
        
        let userTasksCollection = db.collection("users").document(user.uid).collection("tasks")
        
        userTasksCollection.document(documentID).updateData(["enteredGeofence": value]) { error in
            if let error = error {
                print("Failed to update enteredGeofence: \(error.localizedDescription)")
                self.errorMessageFDB = "Something went wrong! Try again"
            } else {
                print("enteredGeofence updated successfully to \(value)")
                self.fetchTasks() // Optional: Fetch tasks again if you want to refresh the data
            }
        }
    }
    
    func updateSaveHistory(for documentID: String, to value: Bool) {
        guard let user = Auth.auth().currentUser else {
            print("No authenticated user found")
            return
        }
        
        let userTasksCollection = db.collection("users").document(user.uid).collection("tasks")
        
        userTasksCollection.document(documentID).updateData(["saveHistory": value]) { error in
            if let error = error {
                print("Failed to update saveHistory: \(error.localizedDescription)")
                self.errorMessageFDB = "Something went wrong! Try again"
            } else {
                print("saveHistory updated successfully to \(value)")
                self.fetchTasks()
            }
        }
    }
    
    func delteAccount() {
        guard let user = Auth.auth().currentUser else {
            print("No authenticated user found")
            return
        }
        
        Future<Void, Error> { promise in
            user.delete { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
            
        }
        .sink(receiveCompletion: {completion in
            switch completion {
            case .failure(let error):
                print("Failed to delete Account: \(error.localizedDescription)")
                self.errorMessageFDB = "Something went wrong! Try logout and login again"
                
            case .finished:
                print("Account deleted successfully")
            }}, receiveValue: { _ in
                
            })
        .store(in: &cancellables)
    }
}
