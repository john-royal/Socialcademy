//
//  PostRowViewModel.swift
//  Socialcademy
//
//  Created by John Royal on 10/12/21.
//

import Foundation

@MainActor
@dynamicMemberLookup
class PostRowViewModel: ObservableObject {
    subscript<T>(dynamicMember keyPath: KeyPath<Post, T>) -> T {
        post[keyPath: keyPath]
    }
    
    enum Route {
        case author, comments
    }
    
    @Published var route: Route?
    @Published var hasError = false
    @Published private var post: Post
    
    private weak var parent: PostViewModel?
    
    init(post: Post, parent: PostViewModel) {
        self.post = post
        self.parent = parent
    }
    
    var canDelete: Bool {
        return parent?.canDelete(post) ?? false
    }
    
    func delete() {
        precondition(canDelete)
        Task {
            do {
                try await parent?.delete(post)
            } catch {
                hasError = true
            }
        }
    }
    
    func toggleFavorite() {
        Task {
            do {
                post.isFavorite.toggle()
                try await parent?.setFavorite(post, to: post.isFavorite)
            } catch {
                post.isFavorite.toggle() // Revert change
                hasError = true
            }
        }
    }
    
    func makeAuthorPostViewModel() -> PostViewModel {
        guard let viewModel = parent?.makeAuthorPostViewModel(for: post.author) else {
            preconditionFailure("Cannot create PostViewModel for author’s posts because the parent PostViewModel is missing")
        }
        return viewModel
    }
    
    func makeCommentViewModel() -> CommentViewModel {
        guard let viewModel = parent?.makeCommentViewModel(for: post) else {
            preconditionFailure("Cannot create CommentViewModel because the parent PostViewModel is missing")
        }
        return viewModel
    }
}
