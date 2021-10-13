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
    
    private typealias Route = PostRowViewModel.Route
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Button {
                viewModel.route = .author
            } label: {
                Text(viewModel.author.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
            }
            if let imageURL = viewModel.imageURL {
                PostImageView(url: imageURL)
            }
            Text(viewModel.title)
                .font(.title3)
                .fontWeight(.semibold)
            Text(viewModel.content)
            HStack {
                FavoriteButton(isFavorite: viewModel.isFavorite, action: {
                    viewModel.toggleFavorite()
                })
                Button {
                    viewModel.route = .comments
                } label: {
                    Label("Comments", systemImage: "text.bubble")
                }
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
        .padding()
        .alert("Error", isPresented: $viewModel.hasError, actions: {}) {
            Text("Sorry, something went wrong.")
        }
        .background {
            NavigationLink(tag: Route.author, selection: $viewModel.route) {
                PostsList(viewModel: viewModel.makeAuthorPostViewModel())
            } label: {
                EmptyView()
            }
            NavigationLink(tag: Route.comments, selection: $viewModel.route) {
                CommentsList(viewModel: viewModel.makeCommentViewModel())
            } label: {
                EmptyView()
            }
        }
    }
}

// MARK: - PostImageView

private extension PostRow {
    struct PostImageView: View {
        let url: URL
        
        var body: some View {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } placeholder: {
                Color.clear
                    .frame(height: 200)
            }
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
        PostRow(viewModel: PostRowViewModel(post: Post.testPost, parent: PostViewModel(postService: PostServiceStub())))
            .previewLayout(.sizeThatFits)
    }
}
#endif
