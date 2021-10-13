//
//  MainTabView.swift
//  Socialcademy
//
//  Created by John Royal on 10/5/21.
//

import SwiftUI

@MainActor
struct MainTabView: View {
    @EnvironmentObject private var viewModel: AuthViewModel
    
    var body: some View {
        TabView {
            PostsList(viewModel: viewModel.makePostViewModel())
                .tabItem {
                    Label("Posts", systemImage: "list.dash")
                }
            PostsList(viewModel: viewModel.makePostViewModel(filter: .favorites))
                .tabItem {
                    Label("Favorites", systemImage: "heart")
                }
            if let user = viewModel.user {
                ProfileView(user: user)
                    .tabItem {
                        Label("Profile", systemImage: "person")
                    }
            }
        }
    }
}

#if DEBUG
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(AuthViewModel.preview())
    }
}
#endif
