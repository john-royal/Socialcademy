//
//  PostService.swift
//  Socialcademy
//
//  Created by John Royal on 10/12/21.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

// MARK: - PostServiceProtocol

protocol PostServiceProtocol {
    func fetchPosts() async throws -> [Post]
    func create(_ post: Post) async throws
}

// MARK: - PostServiceStub

#if DEBUG
struct PostServiceStub: PostServiceProtocol {
    var state: Loadable<[Post]> = .loaded([Post.testPost])
    
    func fetchPosts() async throws -> [Post] {
        return try await state.stub()
    }
    
    func create(_ post: Post) async throws {}
}
#endif

// MARK: - PostService

struct PostService: PostServiceProtocol {
    let postsReference = Firestore.firestore().collection("posts_v1")
    
    func fetchPosts() async throws -> [Post] {
        let snapshot = try await postsReference
            .order(by: "timestamp", descending: true)
            .getDocuments()
        return snapshot.documents.compactMap { document in
            try! document.data(as: Post.self)
        }
    }
    
    func create(_ post: Post) async throws {
        try await postsReference.addDocument(from: post)
    }
}

// MARK: - Private

private extension CollectionReference {
    func addDocument<T: Encodable>(from value: T) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            // Force try is used because this method only throws for encoding errors (other errors are passed to the completion handler).
            // Output is ignored because we don’t have any use for the document reference.
            _ = try! addDocument(from: value) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume()
            }
        }
    }
}
