//
//  NewCommentFormViewModel.swift
//  Socialcademy
//
//  Created by John Royal on 10/13/21.
//

import Foundation

@MainActor
class NewCommentFormViewModel: ObservableObject {
    @Published var content = ""
    
    @Published var isLoading = false
    @Published var hasError = false
    
    private let user: User
    private let submitAction: (Comment) async throws -> Void
    
    init(user: User, submitAction: @escaping (Comment) async throws -> Void) {
        self.user = user
        self.submitAction = submitAction
    }
    
    nonisolated func submitComment() {
        Task {
            await handleSubmit()
        }
    }
    
    private func handleSubmit() async {
        isLoading = true
        
        let comment = Comment(content: content, author: user)
        
        do {
            try await submitAction(comment)
        } catch {
            hasError = true
        }
        isLoading = false
    }
}
