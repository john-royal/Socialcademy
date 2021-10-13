//
//  CommentRowViewModel.swift
//  Socialcademy
//
//  Created by John Royal on 9/23/21.
//

import Foundation

@MainActor
class CommentRowViewModel: ObservableObject {
    let authorName: String
    let timestamp: Date
    let content: String
    
    @Published var hasError = false
    
    private let comment: Comment
    private weak var parent: CommentViewModel?
    
    init(comment: Comment, parent: CommentViewModel) {
        self.authorName = comment.author.name
        self.timestamp = comment.timestamp
        self.content = comment.content
        
        self.comment = comment
        self.parent = parent
    }
    
    var canDelete: Bool {
        return parent?.canDelete(comment) ?? false
    }
    
    func delete() {
        precondition(canDelete)
        Task {
            do {
                try await parent?.delete(comment)
            } catch {
                hasError = true
            }
        }
    }
}
