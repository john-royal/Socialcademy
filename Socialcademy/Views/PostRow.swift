//
//  PostRow.swift
//  Socialcademy
//
//  Created by John Royal on 10/12/21.
//

import SwiftUI

// MARK: - PostRow

struct PostRow: View {
    let post: Post
    let deleteAction: () async throws -> Void
    
    @State private var hasError = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text(post.authorName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                Text(post.timestamp.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
            }
            .foregroundColor(.gray)
            Text(post.title)
                .font(.title3)
                .fontWeight(.semibold)
            Text(post.content)
            HStack {
                Spacer()
                DeleteButton(action: handleDelete)
            }
        }
        .padding(.vertical)
        .alert("Cannot Delete Post", isPresented: $hasError, actions: {}) {
            Text("Sorry, something went wrong.")
        }
    }
    
    private func handleDelete() {
        Task {
            do {
                try await deleteAction()
            } catch {
                hasError = true
            }
        }
    }
}

// MARK: - DeleteButton

private extension PostRow {
    struct DeleteButton: View {
        let action: () -> Void
        
        @State private var isShowingConfirmation = false
        
        var body: some View {
            Button(role: .destructive) {
                isShowingConfirmation = true
            } label: {
                Label("Delete", systemImage: "trash")
                    .labelStyle(.iconOnly)
                    .foregroundColor(.red)
            }
            .buttonStyle(.plain)
            .alert("Are you sure you want to delete this post?", isPresented: $isShowingConfirmation) {
                Button("Delete", role: .destructive, action: action)
            }
        }
    }
}

// MARK: - Preview

struct PostRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            PostRow(post: Post.testPost, deleteAction: {})
        }
    }
}
