//
//  FetchUserIfNeededBackendOperation.swift
//  Instagram_Firebase
//
//  Created by iosDev on 11/1/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

import Foundation

class FetchUserIfNeededBackendOperation: BaseBackendOperation {
    private let userType: UserProfileViewModel.UserType
    private let authorizedUserInfo: AuthorizedUserInfo
    private(set) var user: User?
    
    private enum InternalError: Error {
        case userDataDownloadingError
    }
    
    init(userType: UserProfileViewModel.UserType, authorizedUserInfo: AuthorizedUserInfo) {
        self.userType = userType
        self.authorizedUserInfo = authorizedUserInfo
        super.init()
    }
    
    override func start() {
        fetchUserIfNeeded(input: userType) { [weak self] (user) in
            defer { self?.finish() }
            guard let authorizedUser = user else {
                self?.operationResult = .error(InternalError.userDataDownloadingError)
                return 
            }
            self?.user = authorizedUser
            self?.operationResult = .success
        }
    }
    
    private func fetchUserIfNeeded(input userType: UserProfileViewModel.UserType, completionHandler: @escaping (User?) -> Void) {
        switch userType {
        case .current:
            fetchAuthorizedUser { (user) in
                completionHandler(user)
            }
        case .user(let user):
            completionHandler(user)
        }
    }
    
    private func fetchAuthorizedUser(completionHandler: @escaping ((User?) -> Void)) {
        authorizedUserInfo.fetchAuthorizedUser { (user) in
            guard let user = user else {
                completionHandler(nil)
                return
            }
            completionHandler(user)
        }
    }
}
