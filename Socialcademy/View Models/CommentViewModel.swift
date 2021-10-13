//
//  CommentViewModel.swift
//  Socialcademy
//
//  Created by John Royal on 8/21/21.
//

import Foundation

@MainActor
class CommentViewModel: ObservableObject {
    @Published var comments: Loadable<[Comment]> = .loading
    
    private let commentService: CommentServiceProtocol
    
    init(commentService: CommentServiceProtocol) {
        self.commentService = commentService
    }
    
    func loadComments() {
        comments = .loading
        Task {
            await refreshComments()
        }
    }
    
    func refreshComments() async {
        do {
            comments = .loaded(try await commentService.fetchComments())
        } catch {
            print("[CommentViewModel] Cannot load comments: \(error.localizedDescription)")
            comments = .error(error)
        }
    }
    
    func makeNewCommentFormViewModel() -> NewCommentFormViewModel {
        return NewCommentFormViewModel(user: commentService.user) { [weak self] comment in
            try await self?.commentService.create(comment)
            self?.comments.value?.insert(comment, at: 0)
        }
    }
    
    func canDelete(_ comment: Comment) -> Bool {
        return commentService.canDelete(comment)
    }
    
    func delete(_ comment: Comment) async throws {
        try await commentService.delete(comment)
        comments.value?.removeAll { $0.id == comment.id }
    }
    
    func makeCommentRowViewModel(for comment: Comment) -> CommentRowViewModel {
        return CommentRowViewModel(comment: comment, parent: self)
    }
}
