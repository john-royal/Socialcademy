//
//  AuthService.swift
//  FirebaseTestProject
//
//  Created by John Royal on 8/21/21.
//

import FirebaseAuth

// MARK: - AuthServiceProtocol

protocol AuthServiceProtocol {
    func createAccount(name: String, email: String, password: String) async throws -> User
    func currentUser() -> User?
    func signIn(email: String, password: String) async throws -> User
    func signOut() async throws
}

#if DEBUG
struct AuthServiceStub: AuthServiceProtocol {
    var user: User? = User.testUser
    
    func createAccount(name: String, email: String, password: String) async throws -> User {
        return User(id: email, name: email)
    }
    
    func currentUser() -> User? {
        user
    }
    
    func signIn(email: String, password: String) async throws -> User {
        return User(id: email, name: email)
    }
    
    func signOut() async throws {}
}
#endif

// MARK: - AuthService

struct AuthService: AuthServiceProtocol {
    let auth = Auth.auth()
    
    func createAccount(name: String, email: String, password: String) async throws -> User {
        let result = try await auth.createUser(withEmail: email, password: password)
        
        let changeRequest = result.user.createProfileChangeRequest()
        changeRequest.displayName = name
        try await changeRequest.commitChanges()
        
        return User(from: result.user)
    }
    
    func currentUser() -> User? {
        if let user = auth.currentUser {
            return User(from: user)
        }
        return nil
    }
    
    func signIn(email: String, password: String) async throws -> User {
        let result = try await auth.signIn(withEmail: email, password: password)
        return User(from: result.user)
    }
    
    func signOut() throws {
        try auth.signOut()
    }
}

private extension User {
    init(from user: FirebaseAuth.User) {
        self.id = user.uid
        self.name = user.displayName ?? "User \(user.uid)"
    }
}
