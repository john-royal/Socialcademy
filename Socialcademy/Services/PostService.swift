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
    func fetchFavoritePosts() async throws -> [Post]
    func create(_ post: Post) async throws
    func delete(_ post: Post) async throws
    func favorite(_ post: Post) async throws
    func unfavorite(_ post: Post) async throws
}

// MARK: - PostFilter

enum PostFilter {
    case favorites
}

extension PostServiceProtocol {
    func fetchPosts(matching filter: PostFilter?) async throws -> [Post] {
        switch filter {
        case .none:
            return try await fetchPosts()
        case .favorites:
            return try await fetchFavoritePosts()
        }
    }
}

// MARK: - PostServiceStub

#if DEBUG
struct PostServiceStub: PostServiceProtocol {
    var state: Loadable<[Post]> = .loaded([Post.testPost])
    
    func fetchPosts() async throws -> [Post] {
        return try await state.stub()
    }
    
    func fetchFavoritePosts() async throws -> [Post] {
        return try await state.stub()
    }
    
    func create(_ post: Post) async throws {}
    
    func delete(_ post: Post) async throws {}
    
    func favorite(_ post: Post) async throws {}
    
    func unfavorite(_ post: Post) async throws {}
}
#endif

// MARK: - PostService

struct PostService: PostServiceProtocol {
    let postsReference = Firestore.firestore().collection("posts_v3")
    
    func fetchPosts() async throws -> [Post] {
        let snapshot = try await postsReference
            .order(by: "timestamp", descending: true)
            .getDocuments()
        return snapshot.documents.compactMap { document in
            try! document.data(as: Post.self)
        }
    }
    
    func fetchFavoritePosts() async throws -> [Post] {
        let snapshot = try await postsReference
            .order(by: "timestamp", descending: true)
            .whereField("isFavorite", isEqualTo: true)
            .getDocuments()
        return snapshot.documents.compactMap { document in
            try! document.data(as: Post.self)
        }
    }
    
    func create(_ post: Post) async throws {
        try await documentReference(for: post).setData(from: post)
    }
    
    func delete(_ post: Post) async throws {
        try await documentReference(for: post).delete()
    }
    
    func favorite(_ post: Post) async throws {
        var post = post
        post.isFavorite = true
        try await documentReference(for: post).setData(from: post, merge: true)
    }
    
    func unfavorite(_ post: Post) async throws {
        var post = post
        post.isFavorite = false
        try await documentReference(for: post).setData(from: post, merge: true)
    }
    
    private func documentReference(for post: Post) -> DocumentReference {
        return postsReference.document(post.id.uuidString)
    }
}
