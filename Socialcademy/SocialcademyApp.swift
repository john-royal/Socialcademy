//
//  SocialcademyApp.swift
//  Socialcademy
//
//  Created by John Royal on 1/9/22.
//

import SwiftUI
import Firebase

@main
struct SocialcademyApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            AuthView()
        }
    }
}

extension Date {
    init() {
        self.init(timeIntervalSince1970: 1641739260)
    }
}
