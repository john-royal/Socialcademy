//
//  Firestore+Extensions.swift
//  Socialcademy
//
//  Created by John Royal on 10/12/21.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

extension DocumentReference {
    func setData<T: Encodable>(from value: T) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            // Force try is used because this method only throws for encoding errors (other errors are passed to the completion handler).
            try! setData(from: value) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume()
            }
        }
    }
}
