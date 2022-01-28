//
//  ErrorHandler.swift
//  Socialcademy
//
//  Created by John Royal on 1/9/22.
//

import Foundation

@MainActor
protocol StateHandler: AnyObject {
    var error: Error? { get set }
    var isWorking: Bool { get set }
}

extension StateHandler {
    var isWorking: Bool {
        get { false }
        set {}
    }
}

extension StateHandler {
    typealias Action = () async throws -> Void
    
nonisolated func withStateHandlingTask(perform action: @escaping Action) {
    Task {
        await withStateHandling(perform: action)
    }
}
    
    private func withStateHandling(perform action: @escaping Action) async {
        isWorking = true
        do {
            try await action()
        } catch {
            print("[\(Self.self)] Error: \(error)")
            self.error = error
        }
        isWorking = false
    }
}
