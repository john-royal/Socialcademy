//
//  NewPostFormViewModel.swift
//  Socialcademy
//
//  Created by John Royal on 10/13/21.
//

import Foundation
import UIKit

@MainActor
class NewPostFormViewModel: ObservableObject {
    @Published var title = ""
    @Published var content = ""
    @Published var image: UIImage?
    
    @Published var isLoading = false
    @Published var hasError = false
    @Published var didSubmit = false
    
    private let user: User
    private let submitAction: (Post) async throws -> Void
    private let imageAdapter = ImageStorageAdapter(namespace: "posts")
    
    init(user: User, submitAction: @escaping (Post) async throws -> Void) {
        self.user = user
        self.submitAction = submitAction
    }
    
    nonisolated func submitPost() {
        Task {
            await handleSubmit()
        }
    }
    
    private func handleSubmit() async {
        isLoading = true
        
        var post = Post(title: title, content: content, author: user)
        
        do {
            if let image = image {
                post.imageURL = try await imageAdapter.createImage(image, named: post.id.uuidString)
            }
            try await submitAction(post)
            didSubmit = true
        } catch {
            hasError = true
        }
        isLoading = false
    }
}
