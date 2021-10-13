//
//  Post.swift
//  Socialcademy
//
//  Created by John Royal on 10/11/21.
//

import Foundation

struct Post: Identifiable, Hashable, Equatable {
    var title: String
    var content: String
    var author: User
    var id = UUID()
    var timestamp = Date()
    var isFavorite = false
    
    func contains(_ string: String) -> Bool {
        let properties = [title, content, author.name].map { $0.lowercased() }
        let query = string.lowercased()
        
        let matches = properties.filter { $0.contains(query) }
        return !matches.isEmpty
    }
}

extension Post: Codable {
    enum CodingKeys: CodingKey {
        case title, content, author, id, timestamp
    }
}

extension Post {
    static let testPost = Post(
        title: "Lorem ipsum",
        content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
        author: User.testUser
    )
}
