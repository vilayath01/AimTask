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
        let data: [String: Any] = [
            "dateTime" : Timestamp(date: task.dateTime),
            "taskItems" : task.taskItems,
            "locationName": task.locationName,
            "coordinate" : coordinateData
            
        ]
        
        Future<Void, Error> { promise in
            self.db.collection("users").document(user.uid).collection("tasks").addDocument(data: data) { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
        .sink(receiveCompletion: {_ in}, receiveValue: { _ in
            self.fetchTasks()
        })
        .store(in: &cancellables)
    }
}
