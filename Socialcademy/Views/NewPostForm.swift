//
//  NewPostForm.swift
//  Socialcademy
//
//  Created by John Royal on 10/12/21.
//

import SwiftUI

// MARK: - NewPostForm

struct NewPostForm: View {
    let submitAction: (Post) async throws -> Void
    
    @State private var title = ""
    @State private var content = ""
    
    @State private var didSubmit = false
    @State private var hasError = false
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            Form {
                Section("Title") {
                    TextField("Title", text: $title)
                }
                Section("Content") {
                    TextEditor(text: $content)
                        .multilineTextAlignment(.leading)
                }
                SubmitButton(action: handleSubmit)
            }
            .navigationTitle("New Post")
        }
        .onSubmit(handleSubmit)
        .disabled(didSubmit)
        .alert("Error", isPresented: $hasError, actions: {}) {
            Text("Sorry, something went wrong while creating your post.")
        }
    }
    
    private func handleSubmit() {
        Task {
            didSubmit = true
            do {
                let post = makePost()
                try await submitAction(post)
                dismiss()
            } catch {
                print("[NewPostForm] Error submitting post: \(error.localizedDescription)")
                hasError = true
            }
            didSubmit = false
        }
    }
    
    private func makePost() -> Post {
        guard let user = authViewModel.user else {
            preconditionFailure("Cannot create post without a signed in user")
        }
        return Post(title: title, content: content, author: user)
    }
}

// MARK: - SubmitButton

private extension NewPostForm {
    struct SubmitButton: View {
        let action: () -> Void
        
        @Environment(\.isEnabled) private var isEnabled
        
        var body: some View {
            Button(action: action) {
                Group {
                    if isEnabled {
                        Text("Submit Post")
                            .fontWeight(.semibold)
                    } else {
                        ProgressView()
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .foregroundColor(.white)
            }
            .listRowBackground(Color.accentColor)
            .animation(.default, value: isEnabled)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct NewPostForm_Previews: PreviewProvider {
    static var previews: some View {
        NewPostForm(submitAction: { _ in })
            .environmentObject(AuthViewModel.preview())
    }
}
#endif
