//
//  AuthView.swift
//  Socialcademy
//
//  Created by John Royal on 10/13/21.
//

import SwiftUI

// MARK: - AuthView

struct AuthView: View {
    @StateObject var viewModel = AuthViewModel()
    
    var body: some View {
        if viewModel.user != nil {
            MainTabView()
                .environmentObject(viewModel)
        } else {
            SignInView {
                viewModel.signIn(email: $0, password: $1)
            } createAccountView: {
                CreateAccountView {
                    viewModel.createAccount(name: $0, email: $1, password: $2)
                }
            }
            .disabled(viewModel.isLoading)
            .alert("Error", isPresented: $viewModel.hasError, presenting: viewModel.error, actions: { _ in }) { error in
                Text(error.localizedDescription)
            }
        }
    }
}

// MARK: - SignInView

private extension AuthView {
    struct SignInView<CreateAccountView: View>: View {
        let action: (String, String) -> Void
        @ViewBuilder var createAccountView: () -> CreateAccountView
        
        @State private var email = ""
        @State private var password = ""
        
        var body: some View {
            NavigationView {
                AuthView.Form {
                    TextField("Email Address", text: $email)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                    SecureField("Password", text: $password)
                        .textContentType(.password)
                } button: {
                    Button("Sign In", action: {
                        action(email, password)
                    })
                } footer: {
                    NavigationLink("Create Account", destination: createAccountView())
                }
            }
        }
    }
}

// MARK: - CreateAccountView

private extension AuthView {
    struct CreateAccountView: View {
        let action: (String, String, String) -> Void
        
        @State private var name = ""
        @State private var email = ""
        @State private var password = ""
        
        @Environment(\.dismiss) private var dismiss
        
        var body: some View {
            AuthView.Form {
                TextField("Name", text: $name)
                    .textContentType(.name)
                TextField("Email Address", text: $email)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                SecureField("Password", text: $password)
                    .textContentType(.newPassword)
            } button: {
                Button("Create Account", action: {
                    action(name, email, password)
                })
            } footer: {
                Button("Sign In", action: {
                    dismiss()
                })
            }
        }
    }
}

// MARK: - Form

private extension AuthView {
    struct Form<Fields: View, Footer: View>: View {
        @ViewBuilder var fields: () -> Fields
        @ViewBuilder var button: () -> Button<Text>
        @ViewBuilder var footer: () -> Footer
        
        var body: some View {
            VStack(alignment: .center) {
                Text("Socialcademy")
                    .bold()
                    .font(.title)
                fields()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.secondary.opacity(0.15))
                    .cornerRadius(15)
                button()
                    .buttonStyle(.prominent)
                    .padding(.top)
                footer()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.secondary)
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Previews

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView.SignInView(action: { _, _ in }, createAccountView: EmptyView.init)
        AuthView.CreateAccountView(action: { _, _, _ in })
    }
}
