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

class TaskViewModel: ObservableObject {
    @Published var tasks = [Task]()
    private let db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    func fetchTasks()  {
        Future<[Task], Error> { promise in
            self.db.collection("tasks").getDocuments { querySnapshot, error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    let tasks = querySnapshot?.documents.compactMap({ doc -> Task? in
                        let data = doc.data()
                        let id = doc.documentID
                        let name = data["name"] as? String ?? ""
                        let latitude = data["latitude"] as? Double ?? 0.0
                        let longitude = data["longitude"] as? Double ?? 0.0
                        let location = CLLocation(latitude: latitude, longitude: longitude)
                        let dateTime = (data["dateTime"] as? Timestamp)?.dateValue() ?? Date()
                        return Task(id: id, name: name, location: location, dateTime: dateTime)
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
    
    func addTask(_ task: Task) {
        let data: [String: Any] = [
            "name": task.name,
            "latitude" : task.location.coordinate.latitude,
            "longitude" : task.location.coordinate.longitude,
            "dateTime" : Timestamp(date: task.dateTime)
            
        ]
        
        Future<Void, Error> { promise in
            self.db.collection("tasks").addDocument(data: data) { error in
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
