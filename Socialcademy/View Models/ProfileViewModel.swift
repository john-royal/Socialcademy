//
//  ProfileViewModel.swift
//  Socialcademy
//
//  Created by John Royal on 1/9/22.
//

import Foundation

@MainActor
class ProfileViewModel: ObservableObject, StateHandler {
    @Published var name: String
    @Published var imageURL: URL? {
        didSet {
            imageURLDidChange(from: oldValue)
        }
    }
    @Published var error: Error?
    @Published var isWorking = false
    
    private let authService: AuthService
    
    init(user: User, authService: AuthService) {
        self.name = user.name
        self.imageURL = user.imageURL
        self.authService = authService
    }
    
    func signOut() {
        withStateHandlingTask(perform: authService.signOut)
    }
    
private func imageURLDidChange(from oldValue: URL?) {
    guard imageURL != oldValue else { return }
    withStateHandlingTask { [self] in
        try await authService.updateProfileImage(to: imageURL)
    }
}
}

@MainActor
@dynamicMemberLookup
class ProfileViewModelComplete: ObservableObject, StateHandler {
    @Published var user: User {
        didSet {
            userDidChange(from: oldValue)
        }
    }
    @Published var error: Error?
    @Published var isWorking = false
    
    subscript<T>(dynamicMember keyPath: WritableKeyPath<User, T>) -> T {
        get { user[keyPath: keyPath] }
        set { user[keyPath: keyPath] = newValue }
    }
    
    private let authService: AuthService
    
    init(user: User, authService: AuthService) {
        self.user = user
        self.authService = authService
        
        authService.$user.replaceNil(with: user).assign(to: &$user)
    }
    
    func signOut() {
        withStateHandlingTask(perform: authService.signOut)
    }
    
    private func userDidChange(from oldValue: User) {
        guard user.imageURL != oldValue.imageURL else { return }
        withStateHandlingTask { [self] in
            try await authService.updateProfileImage(to: user.imageURL)
        }
    }
}
