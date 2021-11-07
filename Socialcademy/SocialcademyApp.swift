//
//  SocialcademyApp.swift
//  Socialcademy
//
//  Created by John Royal on 11/1/21.
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
            PostsList()
        }
    }
}
