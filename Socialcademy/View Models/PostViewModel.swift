//
//  PostViewModel.swift
//  Socialcademy
//
//  Created by John Royal on 10/12/21.
//

import Foundation

@MainActor
class PostViewModel: ObservableObject {
    @Published var posts: Loadable<[Post]> = .loading
    
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
                print("[PostViewModel] Cannot load posts: \(error.localizedDescription)")
                posts = .error(error)
            }
        }
    }
    
    func makeDeleteAction(for post: Post) -> () async throws -> Void {
        return { [weak self] in
            try await self?.postService.delete(post)
            self?.posts.value?.removeAll { $0.id == post.id }
        }
    }
    
    func makeSubmitPostAction() -> (Post) async throws -> Void {
        return { [weak self] post in
            try await self?.postService.create(post)
            self?.posts.value?.insert(post, at: 0)
        }
    }
}
