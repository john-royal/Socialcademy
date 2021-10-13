//
//  NewCommentForm.swift
//  Socialcademy
//
//  Created by John Royal on 8/21/21.
//

import SwiftUI

// MARK: - NewCommentForm

struct NewCommentForm: View {
    @StateObject var viewModel: NewCommentFormViewModel
    
    var body: some View {
        HStack {
            TextField("Comment", text: $viewModel.content)
            Button(action: viewModel.submitComment) {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Label("Post", systemImage: "paperplane")
                }
            }
        }
        .onSubmit(viewModel.submitComment)
        .animation(.default, value: viewModel.isLoading)
        .disabled(viewModel.isLoading)
        .alert("Error", isPresented: $viewModel.hasError, actions: {}) {
            Text("Sorry, something went wrong while posting your comment.")
        }
    }
}

// MARK: - Preview

#if DEBUG
struct NewCommentForm_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Text("Preview")
                .toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        NewCommentForm(viewModel: NewCommentFormViewModel(user: User.testUser, submitAction: { _ in }))
                    }
                }
        }
    }
}
#endif
