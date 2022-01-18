//
//  StateHandler.swift
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
    nonisolated func withStateHandlingTask(perform action: @escaping () async throws -> Void) {
        MainActor.runTask { [self] in
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

private extension MainActor {
    static func runTask(body: @escaping @MainActor () async -> Void) {
        Task {
            await body()
        }
    }
}
