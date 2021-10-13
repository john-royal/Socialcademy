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
    @Published var hasError = false
    @Published private var post: Post
    
    subscript<T>(dynamicMember keyPath: KeyPath<Post, T>) -> T {
        post[keyPath: keyPath]
    }
    
    private weak var parent: PostViewModel?
    
    init(post: Post, parent: PostViewModel) {
        self.post = post
        self.parent = parent
    }
    
    func delete() {
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
}
