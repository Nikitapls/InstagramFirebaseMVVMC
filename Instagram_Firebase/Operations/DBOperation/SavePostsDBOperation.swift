//
//  SavePostsDBOperation.swift
//  Instagram_Firebase
//
//  Created by iosDev on 11/2/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

import Foundation

class SavePostsDBOperation: BaseDBOperation {
    private let saveToDBProvider: SaveToDatabaseProvider
    private let posts: [PostWithPostAndUserImage]
    
    init(saveToDBProvider: SaveToDatabaseProvider, posts: [PostWithPostAndUserImage]) {
        self.saveToDBProvider = saveToDBProvider
        self.posts = posts
    }
    
    override func start() {
        do {
            try saveToDBProvider.save(info: posts)
            operationResult = .success
            finish()
        } catch let error {
            operationResult = .error(error)
            finish()
        }
    }
}
