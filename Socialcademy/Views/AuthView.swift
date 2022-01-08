//
//  AuthView.swift
//  Socialcademy
//
//  Created by John Royal on 1/9/22.
//

import SwiftUI

struct AuthView: View {
    @StateObject var viewModel = AuthViewModel()
    
    var body: some View {
        if viewModel.isAuthenticated {
            MainTabView()
        } else {
            NavigationView {
                SignInForm(viewModel: viewModel.makeSignInViewModel()) {
                    NavigationLink("Create Account", destination: CreateAccountForm(viewModel: viewModel.makeCreateAccountViewModel()))
                }
            }
        }
    }
}

private extension AuthView {
    struct SignInForm<Footer: View>: View {
        @StateObject var viewModel: AuthViewModel.FormViewModel
        @ViewBuilder let footer: () -> Footer
        
        var body: some View {
            Form {
                TextField("Email", text: $viewModel.email)
                    .textContentType(.emailAddress)
                SecureField("Password", text: $viewModel.password)
                    .textContentType(.password)
            } footer: {
                Button("Sign In", action: {
                    viewModel.submit()
                })
                    .buttonStyle(.primary)
                footer()
                    .padding()
            }
            .alert("Cannot Sign In", isPresented: $viewModel.hasError, presenting: viewModel.error, actions: { _ in }) {
                Text($0.localizedDescription)
            }
            .disabled(viewModel.isWorking)
        }
    }
}

private extension AuthView {
    struct CreateAccountForm: View {
        @StateObject var viewModel: AuthViewModel.FormViewModel
        
        @Environment(\.dismiss) private var dismiss
        
        var body: some View {
            Form {
                TextField("Email", text: $viewModel.email)
                    .textContentType(.emailAddress)
                SecureField("Password", text: $viewModel.password)
                    .textContentType(.newPassword)
            } footer: {
                Button("Create Account", action: {
                    viewModel.submit()
                })
                    .buttonStyle(.primary)
                Button("Sign In", action: dismiss.callAsFunction)
                    .padding()
            }
            .alert("Cannot Create Account", isPresented: $viewModel.hasError, presenting: viewModel.error, actions: { _ in }) {
                Text($0.localizedDescription)
            }
            .disabled(viewModel.isWorking)
        }
    }
}

private extension AuthView {
    struct Form<Fields: View, Footer: View>: View {
        @ViewBuilder let fields: () -> Fields
        @ViewBuilder let footer: () -> Footer
        
        var body: some View {
            VStack {
                Text("Socialcademy")
                    .font(.title.bold())
                fields()
                    .padding()
                    .background(Color.secondary.opacity(0.15))
                    .cornerRadius(10)
                footer()
            }
            .navigationBarHidden(true)
            .padding()
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
    }
}
