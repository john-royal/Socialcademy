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
    nonisolated func withErrorHandlingTask(perform action: @escaping () async throws -> Void) {
        MainActor.runTask {
            do {
                try await action()
            } catch {
                print("[\(Self.self)] Error: \(error)")
                self.error = error
            }
        }
    }
}

private extension MainActor {
    static func runTask(_ body: @escaping @MainActor () async -> Void) {
        Task {
            await body()
        }
    }
}
