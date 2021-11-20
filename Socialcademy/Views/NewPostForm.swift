//
//  NewPostForm.swift
//  Socialcademy
//
//  Created by John Royal on 11/1/21.
//

import SwiftUI

struct NewPostForm: View {
    let submitAction: (Post) async throws -> Void
    
    @State private var post = Post(title: "", content: "", authorName: "")
    
    @State private var isSubmitting = false
    @State private var hasError = false
    
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
                Button(action: handleSubmit) {
                    if isSubmitting {
                        ProgressView()
                    } else {
                        Text("Submit Post")
                    }
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .foregroundColor(.white)
                .padding()
                .listRowBackground(Color.accentColor)
            }
            .onSubmit(handleSubmit)
            .navigationTitle("New Post")
        }
        .disabled(isSubmitting)
        .alert("Error", isPresented: $hasError, actions: {}) {
            Text("Sorry, something went wrong.")
        }
    }
    
    private func handleSubmit() {
        Task {
            isSubmitting = true
            do {
                try await submitAction(post)
            } catch {
                print("[NewPostForm] Cannot submit post: \(error.localizedDescription)")
                hasError = true
            }
            isSubmitting = false
        }
    }
}

struct NewPostForm_Previews: PreviewProvider {
    static var previews: some View {
        NewPostForm(submitAction: { _ in })
    }
}
