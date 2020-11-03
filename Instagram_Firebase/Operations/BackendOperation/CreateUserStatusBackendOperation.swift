//
//  CreateUserStatusBackendOperation.swift
//  Instagram_Firebase
//
//  Created by iosDev on 11/1/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

import Foundation

class CreateUserStatusBackendOperation: BaseBackendOperation {
    private let userType: UserProfileViewModel.UserType
    private let user: User
    private let followingProvider: FollowingProvider
    private(set) var createdUserStatus: UserStatus?
    
    init(userType: UserProfileViewModel.UserType, user: User, followingProvider: FollowingProvider) {
        self.userType = userType
        self.user = user
        self.followingProvider = followingProvider
        super.init()
    }
    
    override func start() {
        self.createUserStatus(userType: userType, user: user, completionHandler: { [weak self] (userStatus, err) in
            defer { self?.finish() }
            guard err == nil,
                let userStatus = userStatus else {
                    self?.operationResult = .error(err)
                    return
            }
            self?.createdUserStatus = userStatus
            self?.operationResult = .success
        })
    }
    
    private func createUserStatus(userType: UserProfileViewModel.UserType, user: User, completionHandler: @escaping (UserStatus?, Error?) -> Void) {
        if userType == .current {
            completionHandler(.current, nil)
        } else {
            followingProvider.isCurrentUserSubcribedTo(user: user) { (isSubcribed, error) in
                guard error == nil else {
                    completionHandler(nil,error)
                    return
                }
                let userStatus: UserStatus = isSubcribed ? .following : .unfollowing
                completionHandler(userStatus,nil)
            }
        }
    }
}
