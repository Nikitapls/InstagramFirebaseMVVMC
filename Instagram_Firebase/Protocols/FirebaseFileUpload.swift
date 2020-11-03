//
//  FirebaseFileUpload.swift
//  Instagram_Firebase
//
//  Created by iosDev on 7/29/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

import Foundation

protocol FirebaseFileUpload {
    func uploadFile(data: Data?, filename: String, directoryPath: StorageDirectoryPath?, caseError errorHandler: ((Error) -> Void)?, callback: @escaping ((URL) -> Void))
}

