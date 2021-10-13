//
//  MainTabView.swift
//  Socialcademy
//
//  Created by John Royal on 10/5/21.
//

import SwiftUI

@MainActor
struct MainTabView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    
    var body: some View {
        TabView {
            PostsList(viewModel: PostViewModel())
                .tabItem {
                    Label("Posts", systemImage: "list.dash")
                }
            PostsList(viewModel: PostViewModel(filter: .favorites))
                .tabItem {
                    Label("Favorites", systemImage: "heart")
                }
            Button("Sign Out", action: {
                authViewModel.signOut()
            })
                .tabItem {
                    Label("Profile", systemImage: "person")
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
