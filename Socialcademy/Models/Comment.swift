//
//  Comment.swift
//  Socialcademy
//
//  Created by John Royal on 8/20/21.
//

import Foundation

struct Comment: Identifiable, Equatable, Codable {
    var content: String
    var author: User
    var id = UUID()
    var timestamp = Date()
}

extension Comment {
    static let testComment = Comment(content: "Lorem ipsum dolor set amet", author: User.testUser)
}
