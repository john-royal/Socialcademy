//
//  PostService.swift
//  Socialcademy
//
//  Created by John Royal on 11/1/21.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct PostService {
    static let postsReference = Firestore.firestore().collection("posts_v1")
    
    static func create(_ post: Post) async throws {
        let document = postsReference.document(post.id.uuidString)
        try await document.setData(from: post)
    }
}

private extension DocumentReference {
    func setData<T: Encodable>(from value: T) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            // Force try is acceptable here because the method only throws encoding errors, which won’t happen unless there’s a problem with our model. All other errors are passed to the completion handler.
            // Output is ignored because we’re not using the document reference returned from the method.
            _ = try! setData(from: value) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume()
            }
        }
    }
}
