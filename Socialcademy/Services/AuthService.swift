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
        try await result.user.updateProfile(\.displayName, to: name)
        user?.name = name
    }
    
    func signOut() throws {
        try auth.signOut()
    }
    
    func updateProfileImage(to imageFileURL: URL?) async throws {
        guard let firebaseUser = auth.currentUser else {
            preconditionFailure("Cannot update profile for nil user")
        }
        guard let imageFileURL = imageFileURL else {
            return try await firebaseUser.updateProfile(\.photoURL, to: nil)
        }
        let imageURL = try await StorageImage(namespace: "users", identifier: firebaseUser.uid)
            .putFile(from: imageFileURL)
            .getDownloadURL()
        try await firebaseUser.updateProfile(\.photoURL, to: imageURL)
    }
}

private extension User {
    init(from firebaseUser: FirebaseAuth.User) {
        self.id = firebaseUser.uid
        self.name = firebaseUser.displayName ?? ""
        self.imageURL = firebaseUser.photoURL
    }
}

private extension FirebaseAuth.User {
    func updateProfile<T>(_ keyPath: WritableKeyPath<UserProfileChangeRequest, T>, to newValue: T) async throws {
        var profileChangeRequest = createProfileChangeRequest()
        profileChangeRequest[keyPath: keyPath] = newValue
        try await profileChangeRequest.commitChanges()
    }
}
