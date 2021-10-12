//
//  NewPostForm.swift
//  Socialcademy
//
//  Created by John Royal on 10/12/21.
//

import SwiftUI

struct NewPostForm: View {
    let submitAction: (Post) -> Void
    
    @State private var post = Post(title: "", content: "", authorName: "")
    
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
                Button(action: handleSubmit) {
                    Text("Submit Post")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                }
                .listRowBackground(Color.accentColor)
            }
            .onSubmit(handleSubmit)
            .navigationTitle("New Post")
        }
    }
    
    private func handleSubmit() {
        submitAction(post)
        dismiss()
    }
}

struct NewPostForm_Previews: PreviewProvider {
    static var previews: some View {
        NewPostForm(submitAction: { _ in })
    }
}
