//
//  CommentRow.swift
//  Socialcademy
//
//  Created by John Royal on 8/21/21.
//

import SwiftUI

// MARK: - CommentRow

struct CommentRow: View {
    @ObservedObject var viewModel: CommentRowViewModel
    
    @State private var isShowingConfirmation = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Text(viewModel.authorName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                Text(viewModel.timestamp.formatted())
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            Text(viewModel.content)
                .font(.headline)
                .fontWeight(.regular)
        }
        .padding(5)
        .swipeActions {
            if viewModel.canDelete {
                Button(role: .destructive) {
                    isShowingConfirmation = true
                } label: {
                    Label("Delete", systemImage: "trash")
                        .foregroundColor(.red)
                }
            }
        }
        .alert("Are you sure you want to delete this comment?", isPresented: $isShowingConfirmation) {
            Button("Delete", role: .destructive, action: {
                viewModel.delete()
            })
        }
        .alert("Cannot Delete Comment", isPresented: $viewModel.hasError, actions: {}) {
            Text("Sorry, something went wrong.")
        }
    }
}

// MARK: - Preview

#if DEBUG
struct CommentRow_Previews: PreviewProvider {
    static var previews: some View {
        CommentRow(viewModel: CommentRowViewModel(comment: Comment.testComment, parent: CommentViewModel(commentService: CommentServiceStub())))
            .previewLayout(.sizeThatFits)
    }
}
#endif
