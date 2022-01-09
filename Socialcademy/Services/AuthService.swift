//
//  AuthService.swift
//  Socialcademy
//
//  Created by John Royal on 1/9/22.
//

import FirebaseAuth

@MainActor
class AuthService: ObservableObject {
    @Published var isAuthenticated = false
    
    private let auth = Auth.auth()
    private var listener: AuthStateDidChangeListenerHandle?
    
    init() {
        listener = auth.addStateDidChangeListener { [weak self] _, user in
            self?.isAuthenticated = user != nil
        }
    }
    
    func signIn(email: String, password: String) async throws {
        try await auth.signIn(withEmail: email, password: password)
    }
    
    func createAccount(name: String, email: String, password: String) async throws {
        let result = try await auth.createUser(withEmail: email, password: password)
        let profileChangeRequest = result.user.createProfileChangeRequest()
        profileChangeRequest.displayName = name
        try await profileChangeRequest.commitChanges()
    }
    
    func signOut() throws {
        try auth.signOut()
    }
}
