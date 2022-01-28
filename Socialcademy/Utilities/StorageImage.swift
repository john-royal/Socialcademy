//
//  StorageImage.swift
//  Socialcademy
//
//  Created by John Royal on 1/9/22.
//

import Foundation
import FirebaseStorage
import FirebaseStorageSwift

private let storage = Storage.storage()

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
    init(namespace: String, identifier: String) {
        let path = "images/\(namespace)/\(identifier)"
        self.imageReference = storage.reference().child(path)
    }
    
    static func fromURL(_ imageURL: URL) -> StorageImage {
        let imageReference = storage.reference(forURL: imageURL.absoluteString)
        return StorageImage(imageReference: imageReference)
    }
}
