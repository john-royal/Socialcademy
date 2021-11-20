//
//  PostsListViewModel.swift
//  Socialcademy
//
//  Created by John Royal on 11/1/21.
//

import Foundation

@MainActor
class PostsListViewModel: ObservableObject {
    @Published var posts: Loadable<[Post]> = .loading
    @Published var showNewPostForm = false
    
    private let postService: PostServiceProtocol
    
    init(postService: PostServiceProtocol = PostService()) {
        self.postService = postService
    }
    
    func fetchPosts() {
        if posts.value == nil {
            posts = .loading
        }
        Task {
            do {
                posts = .loaded(try await postService.fetchPosts())
            } catch {
                print("[PostsListViewModel] Cannot load posts: \(error.localizedDescription)")
                posts = .error(error)
            }
        }
    }
    
    func submitPost(_ post: Post) async throws {
        try await postService.create(post)
        posts.value?.insert(post, at: 0)
        showNewPostForm = false
    }
}
