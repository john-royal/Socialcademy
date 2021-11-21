//
//  PostService.swift
//  Socialcademy
//
//  Created by John Royal on 11/1/21.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

// MARK: - PostServiceProtocol

protocol PostServiceProtocol {
    func fetchPosts() async throws -> [Post]
    func create(_ post: Post) async throws
    func delete(_ post: Post) async throws
}

// MARK: - PostServiceStub

#if DEBUG
struct PostServiceStub: PostServiceProtocol {
    var state: Loadable<[Post]>
    
    func fetchPosts() async throws -> [Post] {
        return try await state.simulate()
    }
    
    func create(_ post: Post) async throws {}
    
    func delete(_ post: Post) async throws {}
}
#endif

// MARK: - PostService

struct PostService: PostServiceProtocol {
    let postsReference = Firestore.firestore().collection("posts_v1")
    
    func fetchPosts() async throws -> [Post] {
        let query = postsReference.order(by: "timestamp", descending: true)
        let snapshot = try await query.getDocuments()
        let posts = snapshot.documents.compactMap { document in
            try! document.data(as: Post.self)
        }
        return posts
    }
    
    func create(_ post: Post) async throws {
        let document = postsReference.document(post.id.uuidString)
        try await document.setData(from: post)
    }
    
    func delete(_ post: Post) async throws {
        let document = postsReference.document(post.id.uuidString)
        try await document.delete()
    }
}

private extension DocumentReference {
    func setData<T: Encodable>(from value: T) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            // Force try is acceptable here because the method only throws encoding errors, which won’t happen unless there’s a problem with our model. All other errors are passed to the completion handler.
            // Output is ignored because we’re not using the document reference returned from the method.
            _ = try! setData(from: value) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume()
            }
        }
    }
}
