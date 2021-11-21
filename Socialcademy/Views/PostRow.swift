//
//  PostRow.swift
//  Socialcademy
//
//  Created by John Royal on 11/1/21.
//

import SwiftUI

struct PostRow: View {
    typealias DeleteAction = () async throws -> Void
    
    let post: Post
    let deleteAction: DeleteAction
    
    @State private var hasConfirmationDialog = false
    @State private var hasError = false
    @State private var error: Error?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(post.authorName)
                Spacer()
                Text(post.timestamp.formatted(date: .abbreviated, time: .shortened))
            }
            .font(.subheadline)
            .foregroundColor(.gray)
            Text(post.title)
                .font(.title3)
                .fontWeight(.semibold)
            Text(post.content)
            HStack {
                Spacer()
                DeleteButton(action: {
                    hasConfirmationDialog = true
                })
            }
        }
        .padding(.vertical)
        .actionSheet(isPresented: $hasConfirmationDialog) {
            ActionSheet(
                title: Text("Are you sure you want to delete this post?"),
                buttons: [
                    .destructive(Text("Delete"), action: deletePost),
                    .cancel()
                ]
            )
        }
        .alert("Cannot Delete Post", isPresented: $hasError, actions: {}) {
            Text(error?.localizedDescription ?? "Sorry, something went wrong.")
        }
    }
    
    private func deletePost() {
        Task {
            do {
                try await deleteAction()
            } catch {
                self.error = error
                hasError = true
            }
        }
    }
}

private extension PostRow {
    struct DeleteButton: View {
        let action: () -> Void
        
        var body: some View {
            Button(role: .destructive, action: action) {
                Label("Delete", systemImage: "trash")
                    .labelStyle(.iconOnly)
                    .foregroundColor(.red)
            }
            .buttonStyle(.plain)
        }
    }
}

struct PostRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            PostRow(post: Post.testPost, deleteAction: {})
        }
    }
}
