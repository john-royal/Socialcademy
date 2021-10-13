//
//  PostService.swift
//  Socialcademy
//
//  Created by John Royal on 10/12/21.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct PostService {
    let postsReference = Firestore.firestore().collection("posts_v1")
    
    func create(_ post: Post) async throws {
        try await postsReference.addDocument(from: post)
    }
}

private extension CollectionReference {
    func addDocument<T: Encodable>(from value: T) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            // Force try is used because this method only throws for encoding errors (other errors are passed to the completion handler).
            // Output is ignored because we don’t have any use for the document reference.
            _ = try! addDocument(from: value) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume()
            }
        }
    }
}
