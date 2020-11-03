//
//  LoadUserProfileInfoDBOperation.swift
//  Instagram_Firebase
//
//  Created by iosDev on 11/2/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

import Foundation

class LoadUserProfileInfoDBOperation: BaseDBOperation {
    private let currentUIDProvider: CurrentUIDProvider
    private let userType: UserProfileViewModel.UserType
    private let loadFromDBProvider: LoadFromDatabaseProvider
    private(set) var userWithProfileImage: UserWithProfileImage?
    private(set) var posts: [PostWithPostImage] = []
    
    init(currentUIDProvider: CurrentUIDProvider, userType: UserProfileViewModel.UserType, loadFromDBProvider: LoadFromDatabaseProvider) {
        self.currentUIDProvider = currentUIDProvider
        self.userType = userType
        self.loadFromDBProvider = loadFromDBProvider
    }
    
    override func start() {
        let uidOptional: String?
        switch userType {
        case .current:
            uidOptional = currentUIDProvider.currentUid()
        case .user(let user):
            uidOptional = user.uid
        }
        guard let uid = uidOptional else { return }
        loadFromDBProvider.load(uid: uid) { [weak self] (err, dict) in
            defer { self?.finish() }
            guard err == nil,
                let user = dict?.first?.key else {
                    self?.operationResult = .error(err)
                    return
            }
            self?.userWithProfileImage = user
            if let posts = dict?[user]?.sortedByCreationDate(order: .orderedDescending) {
                self?.posts = posts
            }
            self?.operationResult = .success
        }
    }
}
