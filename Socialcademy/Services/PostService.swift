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
    func delete(_ post: Post) async throws
}

// MARK: - PostServiceStub

#if DEBUG
struct PostServiceStub: PostServiceProtocol {
    var state: Loadable<[Post]> = .loaded([Post.testPost])
    
    func fetchPosts() async throws -> [Post] {
        return try await state.stub()
    }
    
    func create(_ post: Post) async throws {}
    
    func delete(_ post: Post) async throws {}
}
#endif

// MARK: - PostService

struct PostService: PostServiceProtocol {
    let postsReference = Firestore.firestore().collection("posts_v2")
    
    func fetchPosts() async throws -> [Post] {
        let snapshot = try await postsReference
            .order(by: "timestamp", descending: true)
            .getDocuments()
        return snapshot.documents.compactMap { document in
            try! document.data(as: Post.self)
        }
    }
    
    func create(_ post: Post) async throws {
        try await postsReference.document(post.id.uuidString).setData(from: post)
    }
    
    func delete(_ post: Post) async throws {
        try await postsReference.document(post.id.uuidString).delete()
    }
}
