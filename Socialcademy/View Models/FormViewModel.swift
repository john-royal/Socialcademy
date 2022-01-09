//
//  FormViewModel.swift
//  Socialcademy
//
//  Created by John Royal on 1/9/22.
//

import Foundation

@dynamicMemberLookup
class FormViewModel<Value>: ObservableObject, StateHandler {
    typealias Action = (Value) async throws -> Void
    
    @Published var value: Value
    
    subscript<T>(dynamicMember keyPath: WritableKeyPath<Value, T>) -> T {
        get { value[keyPath: keyPath] }
        set { value[keyPath: keyPath] = newValue }
    }
    
    @Published var error: Error?
    @Published var isWorking = false
    
    private let action: Action
    
    init(initialValue: Value, action: @escaping Action) {
        self.value = initialValue
        self.action = action
    }
    
    nonisolated func submit() {
        withStateHandlingTask { [weak self] in
            guard let self = self else { return }
            try await self.action(self.value)
        }
    }
}
