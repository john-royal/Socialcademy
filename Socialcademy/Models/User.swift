//
//  User.swift
//  FirebaseTestProject
//
//  Created by John Royal on 8/21/21.
//

import Foundation

struct User: Hashable, Equatable, Codable {
    var id: String
    var name: String
}

extension User {
    static let testUser = User(id: "", name: "Jamie Harris")
}
