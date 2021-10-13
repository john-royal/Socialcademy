//
//  PostRow.swift
//  Socialcademy
//
//  Created by John Royal on 10/12/21.
//

import SwiftUI

// MARK: - PostRow

@MainActor
struct PostRow: View {
    @StateObject var viewModel: PostRowViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(viewModel.author.name)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
            Text(viewModel.title)
                .font(.title3)
                .fontWeight(.semibold)
            Text(viewModel.content)
            HStack {
                FavoriteButton(isFavorite: viewModel.isFavorite, action: {
                    viewModel.toggleFavorite()
                })
                Spacer()
                if viewModel.canDelete {
                    DeleteButton(action: {
                        viewModel.delete()
                    })
                }
                Text(viewModel.timestamp.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.plain)
            .foregroundColor(.gray)
        }
        .padding(.vertical)
        .alert("Error", isPresented: $viewModel.hasError, actions: {}) {
            Text("Sorry, something went wrong.")
        }
    }
}

// MARK: - FavoriteButton

private extension PostRow {
    struct FavoriteButton: View {
        let isFavorite: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                if isFavorite {
                    Label("Remove from Favorites", systemImage: "heart.fill")
                        .foregroundColor(.red)
                } else {
                    Label("Add to Favorites", systemImage: "heart")
                }
            }
            .animation(.default, value: isFavorite)
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
            }
            .alert("Are you sure you want to delete this post?", isPresented: $isShowingConfirmation) {
                Button("Delete", role: .destructive, action: action)
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct PostRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            PostRow(viewModel: PostRowViewModel(post: Post.testPost, parent: PostViewModel(postService: PostServiceStub())))
        }
    }
}
#endif
