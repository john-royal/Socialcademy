//
//  SocialcademyApp.swift
//  Socialcademy
//
//  Created by John Royal on 10/5/21.
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
            MainTabView()
        }
    }
}
