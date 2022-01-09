//
//  AuthViewModel.swift
//  Socialcademy
//
//  Created by John Royal on 1/9/22.
//

import Foundation

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    
    private let authService = AuthService()
    
    init() {
        authService.$isAuthenticated.assign(to: &$isAuthenticated)
    }
    
    func makeSignInViewModel() -> FormViewModel {
        return FormViewModel(submitAction: authService.signIn(email:password:))
    }
    
    func makeCreateAccountViewModel() -> FormViewModel {
        return FormViewModel(submitAction: authService.createAccount(email:password:))
    }
}

extension AuthViewModel {
    class FormViewModel: ObservableObject, StateHandler {
        typealias SubmitAction = (_ email: String, _ password: String) async throws -> Void
        
        @Published var email = ""
        @Published var password = ""
        
        @Published var error: Error?
        @Published var isWorking = false
        
        private let submitAction: SubmitAction
        
        init(submitAction: @escaping SubmitAction) {
            self.submitAction = submitAction
        }
        
        func submit() {
            withStateHandlingTask { [submitAction, email, password] in
                try await submitAction(email, password)
            }
        }
    }
}
