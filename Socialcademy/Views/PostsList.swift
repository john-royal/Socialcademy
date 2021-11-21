//
//  PostsList.swift
//  Socialcademy
//
//  Created by John Royal on 11/1/21.
//

import SwiftUI

struct PostsList: View {
    @StateObject var viewModel = PostsListViewModel()
    
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            Group {
                switch viewModel.posts {
                case .loading:
                    ProgressView()
                case let .error(error):
                    EmptyListView(
                        title: "Cannot Load Posts",
                        message: error.localizedDescription,
                        action: {
                            viewModel.fetchPosts()
                        }
                    )
                case let .loaded(posts) where posts.isEmpty:
                    EmptyListView(
                        title: "No Posts",
                        message: "There aren’t any posts yet."
                    )
                case let .loaded(posts):
                    List(posts) { post in
                        if searchText.isEmpty || post.contains(searchText) {
                            PostRow(
                                post: post,
                                deleteAction: viewModel.makeDeleteAction(for: post)
                            )
                        }
                    }
                    .searchable(text: $searchText)
                    .animation(.default, value: posts)
                }
            }
            .navigationTitle("Posts")
            .toolbar {
                Button {
                    viewModel.showNewPostForm = true
                } label: {
                    Label("New Post", systemImage: "square.and.pencil")
                }
            }
            .sheet(isPresented: $viewModel.showNewPostForm) {
                NewPostForm(submitAction: viewModel.submitPost(_:))
            }
        }
        .onAppear {
            viewModel.fetchPosts()
        }
    }
}

#if DEBUG
struct PostsList_Previews: PreviewProvider {
    static var previews: some View {
        ListPreview(state: .loaded([Post.testPost]))
        ListPreview(state: .loaded([]))
        ListPreview(state: .error)
        ListPreview(state: .loading)
    }
    
    @MainActor
    private struct ListPreview: View {
        let state: Loadable<[Post]>
        
        var body: some View {
            let postService = PostServiceStub(state: state)
            let viewModel = PostsListViewModel(postService: postService)
            PostsList(viewModel: viewModel)
        }
    }
}
#endif
