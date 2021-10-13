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
    
    func makePostRowViewModel(for post: Post) -> PostRowViewModel {
        return PostRowViewModel(post: post, parent: self)
    }
    
    func submit(_ post: Post) async throws {
        try await postService.create(post)
        posts.value?.insert(post, at: 0)
    }
    
    func delete(_ post: Post) async throws {
        try await postService.delete(post)
        posts.value?.removeAll { $0.id == post.id }
    }
    
    func setFavorite(_ post: Post, to isFavorite: Bool) async throws {
        try await isFavorite ? postService.favorite(post) : postService.unfavorite(post)
        
        guard let i = posts.value?.firstIndex(of: post) else { return }
        posts.value?[i].isFavorite = isFavorite
    }
}
