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
    @Published var listItem = [ListItem]()
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
    
    func addListItem(_ listItem: ListItem) {
        let data: [String: Any] = [
            "id": listItem.id,
            "text" : listItem.text,
            "isChecked" : listItem.isChecked,
        ]
        
        Future<Void, Error> { promise in
            self.db.collection("listItems").addDocument(data: data) { error in
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
    
    func fetchListItems() {
        Future<[ListItem], Error> { promise in
            self.db.collection("listItems").getDocuments { querySnapshot, error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    let listItem = querySnapshot?.documents.compactMap({ doc -> ListItem? in
                        let data = doc.data()
                        guard
                            let text = data["text"] as? String,
                            let isChecked = data["isChecked"] as? Bool
                        else {return nil}
                        
                        return ListItem(text:  text, isChecked: isChecked)
                    }) ?? []
                    promise(.success(listItem))
                }
            }
            
        }
        .replaceError(with: [])
        .receive(on: DispatchQueue.main)
        .assign(to: \.listItem, on: self)
        .store(in: &cancellables)
    }
}
