//
//  MainTabView.swift
//  Socialcademy
//
//  Created by John Royal on 10/5/21.
//

import SwiftUI

struct MainTabView: View {
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
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
