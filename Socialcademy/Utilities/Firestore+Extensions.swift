//
//  Firestore+Extensions.swift
//  Socialcademy
//
//  Created by John Royal on 10/12/21.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

extension CollectionReference {
    func addDocument<T: Encodable>(from value: T) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            // Force try is used because this method only throws for encoding errors (other errors are passed to the completion handler).
            // Output is ignored because we don’t have any use for the resulting document reference.
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

extension DocumentReference {
    func setData<T: Encodable>(from value: T, merge: Bool = false) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            // Force try is used because this method only throws for encoding errors (other errors are passed to the completion handler).
            try! setData(from: value, merge: merge) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume()
            }
        }
    }
}

extension Query {
    func getDocuments<T: Decodable>(as type: T.Type) async throws -> [T] {
        let snapshot = try await getDocuments()
        return snapshot.documents.compactMap { document in
            try! document.data(as: type)
        }
    }
}
