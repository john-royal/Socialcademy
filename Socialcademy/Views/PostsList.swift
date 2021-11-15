//
//  PostsList.swift
//  Socialcademy
//
//  Created by John Royal on 11/1/21.
//

import SwiftUI

struct PostsList: View {
    @State private var posts = [Post.testPost]
    
    @State private var searchText = ""
    @State private var showNewPostForm = false
    
    var body: some View {
        NavigationView {
            List(posts) { post in
                if searchText.isEmpty || post.contains(searchText) {
                    PostRow(post: post)
                }
            }
            .searchable(text: $searchText)
            .navigationTitle("Posts")
            .toolbar {
                Button {
                    showNewPostForm = true
                } label: {
                    Label("New Post", systemImage: "square.and.pencil")
                }
            }
            .sheet(isPresented: $showNewPostForm) {
                NewPostForm(submitAction: { post in
                    try await PostService.create(post)
                    posts.insert(post, at: 0)
                    showNewPostForm = false
                })
            }
        }
    }
}

struct PostsList_Previews: PreviewProvider {
    static var previews: some View {
        PostsList()
    }
}
