//
//  FirebaseService+FirebaseFileUpload.swift
//  Instagram_Firebase
//
//  Created by iosDev on 8/18/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

import Foundation
import FirebaseStorage

extension FirebaseService: FirebaseFileUpload {
    
    func uploadFile(data: Data?, filename: String, directoryPath: StorageDirectoryPath?, caseError errorHandler: ((Error) -> Void)?, callback: @escaping ((URL) -> Void)) {
        guard let data = data else { return }
        let reference: StorageReference?
        if let directoryPath = directoryPath {
            reference = Storage.storage().reference().child(directoryPath.rawValue).child(filename)
        } else {
            reference = Storage.storage().reference().child(filename)
        }
        guard let storageReference = reference else { return }
        storageReference.putData(data, metadata: nil) { (metadata, err) in
            if let error = err {
                errorHandler?(error)
                return
            }
            guard metadata != nil else {
                return
            }
            storageReference.downloadURL { (url, error) in
                if let error = err {
                    errorHandler?(error)
                    return
                }
                guard let downloadURL = url else {
                    return
                }
                callback(downloadURL)
            }
        }
    }
}
