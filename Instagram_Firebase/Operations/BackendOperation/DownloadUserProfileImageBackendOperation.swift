//
//  DownloadUserProfileImageBackendOperation.swift
//  Instagram_Firebase
//
//  Created by iosDev on 11/1/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

import Foundation

class DownloadUserProfileImageBackendOperation: BaseBackendOperation {
    private let user: User
    private let fileDownloader: FileDownloader
    private(set) var userWithProfileImage: UserWithProfileImage?
    private enum InternalError: Error {
        case userImageDownloadError
    }
    
    init(user: User, fileDownloader: FileDownloader) {
        self.user = user
        self.fileDownloader = fileDownloader
        super.init()
    }
    
    override func start() {
        downloadUserImage(user: user, completionHandler: { (userWithProfileImage) in
            defer { self.finish() }
            guard let userWithProfileImage = userWithProfileImage else {
                self.operationResult = .error(InternalError.userImageDownloadError)
                return
            }
            self.userWithProfileImage = userWithProfileImage
            self.operationResult = .success
        })
    }
    
    private func downloadUserImage(user: User, completionHandler: @escaping (UserWithProfileImage?) -> Void) {
        fileDownloader.downloadProfileImagesForUsers(users: [user]) { (err, users) in
            guard err == nil, let users = users else {
                print(err ?? "err")
                return
            }
            guard users.count == 1 else {
                completionHandler(nil)
                return
            }
            completionHandler(users[0])
        }
    }
}
