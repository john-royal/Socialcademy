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
    var user: User { get }
    
    func fetchPosts() async throws -> [Post]
    func fetchPosts(by author: User) async throws -> [Post]
    func fetchFavoritePosts() async throws -> [Post]
    func create(_ post: Post) async throws
    func delete(_ post: Post) async throws
    func favorite(_ post: Post) async throws
    func unfavorite(_ post: Post) async throws
}

extension PostServiceProtocol {
    func canDelete(_ post: Post) -> Bool {
        user.id == post.author.id
    }
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
    var user = User.testUser
    
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
    let user: User
    let postsReference = Firestore.firestore().collection("posts_v4")
    let favoritesReference = Firestore.firestore().collection("favorites")
    
    func fetchPosts() async throws -> [Post] {
        let favorites = try await fetchFavorites()
        return try await postsReference
            .order(by: "timestamp", descending: true)
            .getDocuments(as: Post.self)
            .map {
                Post($0, isFavorite: favorites.contains($0.id))
            }
    }
    
    func fetchFavoritePosts() async throws -> [Post] {
        let favorites = try await fetchFavorites()
        if favorites.isEmpty {
            // Skip the Firestore query and return an empty array of posts.
            // This is a workaround for Firestore crashing when performing a where-in query with no allowed values.
            return []
        }
        return try await postsReference
            .order(by: "timestamp", descending: true)
            .whereField("id", in: favorites.map(\.uuidString))
            .getDocuments(as: Post.self)
            .map {
                Post($0, isFavorite: true)
            }
    }
    
    func create(_ post: Post) async throws {
        try await postsReference.document(post.id.uuidString).setData(from: post)
    }
    
    func delete(_ post: Post) async throws {
        try await postsReference.document(post.id.uuidString).delete()
    }
    
    func favorite(_ post: Post) async throws {
        let favorite = Favorite(postID: post.id, userID: user.id)
        try await favoritesReference.addDocument(from: favorite)
    }
    
    func unfavorite(_ post: Post) async throws {
        let snapshot = try await favoritesReference
            .whereField("postID", isEqualTo: post.id.uuidString)
            .whereField("userID", isEqualTo: user.id)
            .getDocuments()
        assert(snapshot.count == 1)
        guard let documentReference = snapshot.documents.first?.reference else { return }
        try await documentReference.delete()
    }
}

private extension PostService {
    func fetchFavorites() async throws -> [Post.ID] {
        return try await favoritesReference
            .whereField("userID", isEqualTo: user.id)
            .getDocuments(as: Favorite.self)
            .map(\.postID)
    }
    
    struct Favorite: Codable {
        let postID: Post.ID
        let userID: User.ID
    }
}

private extension Post {
    init(_ post: Post, isFavorite: Bool) {
        self.title = post.title
        self.content = post.content
        self.author = post.author
        self.id = post.id
        self.timestamp = post.timestamp
        self.isFavorite = isFavorite
    }
}
