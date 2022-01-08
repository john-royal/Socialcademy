//
//  ErrorHandler.swift
//  Socialcademy
//
//  Created by John Royal on 1/9/22.
//

import Foundation

@MainActor
protocol ErrorHandler: AnyObject {
    var error: Error? { get set }
}

extension ErrorHandler {
    var hasError: Bool {
        get { error != nil }
        set {
            guard !newValue else { return }
            error = nil
        }
    }
}

extension ErrorHandler {
    func withErrorHandlingTask(perform action: @escaping () async throws -> Void) {
        Task {
            do {
                try await action()
            } catch {
                print("[\(Self.self)] Error: \(error)")
                self.error = error
            }
        }
    }
}
