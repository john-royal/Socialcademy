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
    var hasError: Bool {
        get { error != nil }
        set {
            guard !newValue else { return }
            error = nil
        }
    }
    
    var isWorking: Bool {
        get { false }
        set {}
    }
    
    func withStateHandlingTask(perform action: @escaping () async throws -> Void) {
        Task {
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
}
