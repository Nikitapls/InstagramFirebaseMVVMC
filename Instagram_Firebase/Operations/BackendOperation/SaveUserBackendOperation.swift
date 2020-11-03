//
//  SaveUserBackendOperation.swift
//  Instagram_Firebase
//
//  Created by iosDev on 10/21/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

import UIKit.UIImage

class SaveUserBackendOperation: BaseBackendOperation {
    
    private let profileImage: UIImage?
    private let username: String
    private let password: String
    private let email: String
    
    private let userRegistration: UserRegistration
    
    init(username: String, email: String, password: String, profilePhoto: UIImage?, userRegistrationService: UserRegistration) {
        self.profileImage = profilePhoto
        self.password = password
        self.email = email
        self.username = username
        self.userRegistration = userRegistrationService
        super.init()
    }
    
    override func start() {
        userRegistration.registerUser(username: username,
                                      email: email,
                                      password: password,
                                      profilePhoto: profileImage ) { [weak self] (error) in
                                        defer {
                                            self?.finish()
                                        }
                                        guard error == nil else {
                                            self?.operationResult = .error(error)
                                            return
                                        }
                                        self?.operationResult = .success
        }
    }
}
