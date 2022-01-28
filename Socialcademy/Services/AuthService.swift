//
//  AuthService.swift
//  Socialcademy
//
//  Created by John Royal on 1/9/22.
//

import FirebaseAuth

@MainActor
class AuthService: ObservableObject {
    @Published var user: User?
    
    private let auth = Auth.auth()
    private var listener: AuthStateDidChangeListenerHandle?
    
    init() {
        listener = auth.addStateDidChangeListener { [weak self] _, user in
            self?.user = user.map { User(from: $0) }
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
    
    func updateProfileImage(to imageFileURL: URL?) async throws {
        guard let firebaseUser = auth.currentUser else {
            preconditionFailure("Cannot update profile for nil user")
        }
        let imageURL: URL? = try await {
            guard let imageFileURL = imageFileURL else {
                return nil
            }
            return try await StorageImage(namespace: "users", identifier: firebaseUser.uid)
                .putFile(from: imageFileURL)
                .getDownloadURL()
        }()
        let profileChangeRequest = firebaseUser.createProfileChangeRequest()
        profileChangeRequest.photoURL = imageURL
        try await profileChangeRequest.commitChanges()
    }
}

private extension User {
    init(from firebaseUser: FirebaseAuth.User) {
        self.id = firebaseUser.uid
        self.name = firebaseUser.displayName ?? ""
        self.imageURL = firebaseUser.photoURL
    }
}
