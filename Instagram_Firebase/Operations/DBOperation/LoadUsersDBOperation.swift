//
//  LoadUsersDBOperation.swift
//  Instagram_Firebase
//
//  Created by iosDev on 11/2/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

import Foundation

class LoadUsersDBOperation: BaseDBOperation {
    private let loadFromDatabaseProvider: LoadFromDatabaseProvider
    private(set) var loadedUsers: [UserWithProfileImage] = []
    init(loadFromDBProvider: LoadFromDatabaseProvider) {
        self.loadFromDatabaseProvider = loadFromDBProvider
    }
    
    override func start() {
        loadFromDatabaseProvider.loadUsers { (err, users) in
            defer { self.finish() }
            guard err == nil,
                let users = users else {
                    operationResult = .error(err)
                    return
            }
            loadedUsers = users
            operationResult = .success
        }
    }
}
