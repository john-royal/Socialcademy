//
//  PostsList.swift
//  Socialcademy
//
//  Created by John Royal on 10/11/21.
//

import SwiftUI

// MARK: - PostsList

struct PostsList: View {
    @StateObject var viewModel: PostViewModel
    
    @State private var showNewPostForm = false
    
    var body: some View {
        if viewModel.isRootView {
            NavigationView {
                InternalListView(viewModel: viewModel)
                    .toolbar {
                        Button {
                            showNewPostForm = true
                        } label: {
                            Label("New Post", systemImage: "square.and.pencil")
                        }
                    }
                    .sheet(isPresented: $showNewPostForm) {
                        NewPostForm(submitAction: { post in
                            try await viewModel.submit(post)
                        })
                    }
            }
        } else {
            InternalListView(viewModel: viewModel)
        }
    }
}

// MARK: - InternalListView

private extension PostsList {
    struct InternalListView: View {
        @StateObject var viewModel: PostViewModel
        
        @State private var searchText = ""
        
        var body: some View {
            Group {
                switch viewModel.posts {
                case .loading:
                    ProgressView()
                case let .error(error):
                    EmptyListView(
                        title: "Cannot Load Posts",
                        message: error.localizedDescription,
                        retryAction: { viewModel.fetchPosts() }
                    )
                case .empty:
                    EmptyListView(
                        title: "No Posts",
                        message: "There are no posts here."
                    )
                case let .loaded(posts):
                    ScrollView {
                        ForEach(posts) { post in
                            if searchText.isEmpty || post.contains(searchText) {
                                PostRow(viewModel: viewModel.makePostRowViewModel(for: post))
                                if post != posts.last {
                                    Divider()
                                }
                            }
                        }
                    }
                    .searchable(text: $searchText)
                    .animation(.default, value: posts)
                }
            }
            .navigationTitle(title)
            .onAppear {
                viewModel.fetchPosts()
            }
        }
        
        private var title: String {
            switch viewModel.filter {
            case .none:
                return "Socialcademy"
            case .favorites:
                return "Favorites"
            case let .author(author):
                return "\(author.name)’s Posts"
            }
        }
    }
}

// MARK: - Previews

#if DEBUG
struct PostsList_Previews: PreviewProvider {
    static var previews: some View {
        ListPreview(state: .loaded([Post.testPost]))
        ListPreview(state: .empty)
        ListPreview(state: .error)
        ListPreview(state: .loading)
    }
    
    @MainActor
    private struct ListPreview: View {
        let state: Loadable<[Post]>
        
        var body: some View {
            PostsList(viewModel: PostViewModel(postService: PostServiceStub(state: state)))
        }
    }
}
#endif
