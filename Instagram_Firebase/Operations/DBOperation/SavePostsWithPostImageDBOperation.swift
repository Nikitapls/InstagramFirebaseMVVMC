//
//  SaveUserProfileAndPostsDBOperation.swift
//  Instagram_Firebase
//
//  Created by iosDev on 11/2/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

import Foundation

class SavePostsWithPostImageDBOperation: BaseDBOperation {
    private let saveToDBProvider: SaveToDatabaseProvider
    private let dict: [FirebaseService.RemoteUID: [PostWithPostImage]]
    
    init(saveToDBProvider: SaveToDatabaseProvider, save dict: [FirebaseService.RemoteUID: [PostWithPostImage]]) {
        self.saveToDBProvider = saveToDBProvider
        self.dict = dict
    }
    
    override func start() {
        do {
            try saveToDBProvider.save(dict: dict)
            operationResult = .success
            finish()
        } catch let err {
            operationResult = .error(err)
            finish()
        }
    }
}
