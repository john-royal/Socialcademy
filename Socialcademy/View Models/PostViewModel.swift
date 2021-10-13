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
    
    let filter: PostFilter?
    let isRootView: Bool
    
    private let postService: PostServiceProtocol
    
    init(postService: PostServiceProtocol, filter: PostFilter? = .none, isRootView: Bool = true) {
        self.postService = postService
        self.filter = filter
        self.isRootView = isRootView
    }
    
    func fetchPosts() {
        if posts.value == nil {
            posts = .loading
        }
        Task {
            do {
                posts = .loaded(try await postService.fetchPosts(matching: filter))
            } catch {
                print("[PostViewModel] Cannot load posts: \(error.localizedDescription)")
                posts = .error(error)
            }
        }
    }
    
    func makePostRowViewModel(for post: Post) -> PostRowViewModel {
        return PostRowViewModel(post: post, parent: self)
    }
    
    func makeAuthorPostViewModel(for author: User) -> PostViewModel {
        return PostViewModel(postService: postService, filter: .author(author), isRootView: false)
    }
    
    func makeCommentViewModel(for post: Post) -> CommentViewModel {
        return CommentViewModel(commentService: CommentService(post: post, user: postService.user))
    }
    
    func makeNewPostFormViewModel() -> NewPostFormViewModel {
        return NewPostFormViewModel(user: postService.user, submitAction: { [weak self] post in
            try await self?.postService.create(post)
            self?.posts.value?.insert(post, at: 0)
        })
    }
    
    func canDelete(_ post: Post) -> Bool {
        return postService.canDelete(post)
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
