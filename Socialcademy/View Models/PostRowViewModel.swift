//
//  PostRowViewModel.swift
//  Socialcademy
//
//  Created by John Royal on 1/9/22.
//

import Foundation

@MainActor
@dynamicMemberLookup
class PostRowViewModel: ObservableObject, ErrorHandler {
    typealias Action = () async throws -> Void
    
    @Published var post: Post
    @Published var error: Error?
    
    subscript<T>(dynamicMember keyPath: KeyPath<Post, T>) -> T {
        post[keyPath: keyPath]
    }
    
    private let deleteAction: Action
    private let favoriteAction: Action
    
    init(post: Post, deleteAction: @escaping Action, favoriteAction: @escaping Action) {
        self.post = post
        self.deleteAction = deleteAction
        self.favoriteAction = favoriteAction
    }
    
    nonisolated func deletePost() {
        withErrorHandlingTask(perform: deleteAction)
    }
    
    nonisolated func favoritePost() {
        withErrorHandlingTask(perform: favoriteAction)
    }
}
