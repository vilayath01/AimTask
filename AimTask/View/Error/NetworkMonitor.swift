//
//  NetworkMonitor.swift
//  AimTask
//
//  Created by Vilayath Mohammed on 2/9/2024.
//

import Network
import Combine

class NetworkMonitor: ObservableObject {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .background)
    
    @Published var isConnected: Bool = true
    
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                if path.status == .satisfied {
                    self?.isConnected = true
                    print("Network status changed: true")
                    print("Network is connected")
                } else {
                    self?.isConnected = false
                    print("Network status changed: false")
                    print("Network is disconnected")
                }
            }
        }
        monitor.start(queue: queue)
    }
    
    deinit {
        monitor.cancel()
    }
}
