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
    
    @State private var post = Post(title: "", content: "", authorName: "")
    @State private var didSubmit = false
    @State private var hasError = false
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Title", text: $post.title)
                    TextField("Author Name", text: $post.authorName)
                }
                Section("Content") {
                    TextEditor(text: $post.content)
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
                try await submitAction(post)
                dismiss()
            } catch {
                print("[NewPostForm] Error submitting post: \(error.localizedDescription)")
                hasError = true
            }
            didSubmit = false
        }
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

struct NewPostForm_Previews: PreviewProvider {
    static var previews: some View {
        NewPostForm(submitAction: { _ in })
    }
}
