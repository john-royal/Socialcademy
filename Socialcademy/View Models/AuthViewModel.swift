//
//  AuthViewModel.swift
//  Socialcademy
//
//  Created by John Royal on 10/13/21.
//

import Foundation

@MainActor
class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var error: Error?
    @Published var hasError = false
    @Published var isLoading = false
    
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol = AuthService()) {
        self.user = authService.currentUser()
        self.authService = authService
    }
    
    func signIn(email: String, password: String) {
        performTask { [weak self] in
            self?.user = try await self?.authService.signIn(email: email, password: password)
        }
    }
    
    func createAccount(name: String, email: String, password: String) {
        performTask { [weak self] in
            self?.user = try await self?.authService.createAccount(name: name, email: email, password: password)
        }
    }
    
    func signOut() {
        performTask { [weak self] in
            try await self?.authService.signOut()
            self?.user = nil
        }
    }
    
    private func performTask(action: @escaping () async throws -> Void) {
        Task {
            isLoading = true
            do {
                try await action()
            } catch {
                print("[AuthViewModel] Error: \(error.localizedDescription)")
                self.error = error
                hasError = true
            }
            isLoading = false
        }
    }
}
