//
//  Loadable.swift
//  Socialcademy
//
//  Created by John Royal on 11/1/21.
//

import Foundation

enum Loadable<Value> {
    case loading, error(Error), loaded(Value)
}

extension Loadable {
    var value: Value? {
        get {
            guard case let .loaded(value) = self else {
                return nil
            }
            return value
        }
        set {
            guard let newValue = newValue else {
                return
            }
            self = .loaded(newValue)
        }
    }
}

#if DEBUG
extension Loadable {
    func simulate() async throws -> Value {
        switch self {
        case .loading:
            await Task.sleep(10 * 1_000_000_000)
            fatalError("Timeout exceeded for “loading” case.")
        case let .error(error):
            throw error
        case let .loaded(value):
            return value
        }
    }
    
    static var error: Loadable<Value> {
        return .error(PreviewError())
    }
    
    private struct PreviewError: LocalizedError {
        let errorDescription: String? = "Lorem ipsum dolor set amet."
    }
}
#endif

