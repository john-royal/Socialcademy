//
//  AuthViewModel.swift
//  Socialcademy
//
//  Created by John Royal on 10/13/21.
//

import Foundation
import UIKit

@MainActor
class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var error: Error?
    @Published var hasError = false
    @Published var isLoading = false
    
    private let authService: AuthServiceProtocol
    private let imageAdapter = ImageStorageAdapter(namespace: "users")
    
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
    
    func updateProfileImage(_ image: UIImage) {
        performTask { [weak self] in
            guard var user = self?.user,
                  let imageURL = try await self?.imageAdapter.createImage(image, named: user.id) else {
                      return
                  }
            user.imageURL = imageURL
            try await self?.authService.update(user)
            self?.user = user
        }
    }
    
    func removeProfileImage() {
        performTask { [weak self] in
            guard var user = self?.user else { return }
            try await self?.imageAdapter.deleteImage(named: user.id)
            
            user.imageURL = nil
            try await self?.authService.update(user)
            self?.user = user
        }
    }
    
    func makePostViewModel(filter: PostFilter? = nil) -> PostViewModel {
        guard let user = user else {
            preconditionFailure("Cannot display posts without a signed-in user")
        }
        return PostViewModel(postService: PostService(user: user), filter: filter)
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

#if DEBUG
extension AuthViewModel {
    static func preview(user: User? = User.testUser) -> AuthViewModel {
        return AuthViewModel(authService: AuthServiceStub(user: user))
    }
}
#endif
