//
//  StorageImage.swift
//  Socialcademy
//
//  Created by John Royal on 1/9/22.
//

import Foundation
import FirebaseStorage
import FirebaseStorageSwift

struct StorageImage {
    private let imageReference: StorageReference
    
    func putFile(from fileURL: URL) async throws -> Self {
        _ = try await imageReference.putFileAsync(from: fileURL)
        return self // for method chaining
    }
    
    func getDownloadURL() async throws -> URL {
        return try await imageReference.downloadURL()
    }
    
    func delete() async throws {
        try await imageReference.delete()
    }
}

extension StorageImage {
    private static let storage = Storage.storage()
    
    static func create() -> StorageImage {
        let id = UUID().uuidString
        let path = "images/\(id)"
        let imageReference = storage.reference().child(path)
        return StorageImage(imageReference: imageReference)
    }
    
    static func fromURL(_ imageURL: URL) -> StorageImage {
        let imageReference = storage.reference(forURL: imageURL.absoluteString)
        return StorageImage(imageReference: imageReference)
    }
}
