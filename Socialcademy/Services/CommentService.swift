//
//  CommentService.swift
//  Socialcademy
//
//  Created by John Royal on 8/30/21.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

// MARK: - CommentServiceProtocol

protocol CommentServiceProtocol {
    var post: Post { get }
    var user: User { get }
    
    func fetchComments() async throws -> [Comment]
    
    func create(_ comment: Comment) async throws
    func delete(_ comment: Comment) async throws
    
    func canDelete(_ comment: Comment) -> Bool
}

extension CommentServiceProtocol {
    func canDelete(_ comment: Comment) -> Bool {
        [post.author.id, comment.author.id].contains(user.id)
    }
}

// MARK: - CommentServiceStub

#if DEBUG
struct CommentServiceStub: CommentServiceProtocol {
    var state: Loadable<[Comment]> = .loaded([Comment.testComment])
    
    let post = Post.testPost
    let user = User.testUser
    
    func fetchComments() async throws -> [Comment] {
        return try await state.stub()
    }
    
    func create(_ comment: Comment) async throws {}
    
    func delete(_ comment: Comment) async throws {}
}
#endif

// MARK: - CommentService

struct CommentService: CommentServiceProtocol {
    let post: Post
    let user: User
    let commentsReference: CollectionReference
    
    func fetchComments() async throws -> [Comment] {
        return try await commentsReference.order(by: "timestamp", descending: true).getDocuments(as: Comment.self)
    }
    
    func create(_ comment: Comment) async throws {
        try await commentsReference.document(comment.id.uuidString).setData(from: comment)
    }
    
    func delete(_ comment: Comment) async throws {
        precondition(canDelete(comment), "User not authorized to delete comment")
        let commentReference = commentsReference.document(comment.id.uuidString)
        try await commentReference.delete()
    }
}

extension CommentService {
    init(post: Post, user: User) {
        self.post = post
        self.user = user
        
        let firestore = Firestore.firestore()
        let postReference = firestore.collection("posts").document(post.id.uuidString)
        self.commentsReference = postReference.collection("comments")
    }
}
