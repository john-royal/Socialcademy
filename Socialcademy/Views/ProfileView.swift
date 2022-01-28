//
//  ProfileView.swift
//  Socialcademy
//
//  Created by John Royal on 1/9/22.
//

import SwiftUI

struct ProfileView: View {
    @StateObject var viewModel: ProfileViewModel
    
var body: some View {
    NavigationView {
        VStack {
            Spacer()
            ProfileImage(url: viewModel.imageURL)
                .frame(width: 200, height: 200)
                Spacer()
                Text(viewModel.name)
                    .font(.title2)
                    .bold()
                    .padding()
                ImagePickerButton(imageURL: $viewModel.imageURL) {
                    Label("Choose Image", systemImage: "photo.fill")
                }
                Spacer()
            }
            .navigationTitle("Profile")
            .toolbar {
                Button("Sign Out", action: {
                    viewModel.signOut()
                })
            }
        }
.alert("Error", error: $viewModel.error)
.disabled(viewModel.isWorking)
    }
}

private extension ProfileView {
    struct ProfileImage: View {
        let url: URL?
        
        var body: some View {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Color.clear
            }
            .frame(width: 200, height: 200)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.gray.opacity(0.5)))
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(viewModel: ProfileViewModel(user: User.testUser, authService: AuthService()))
    }
}
