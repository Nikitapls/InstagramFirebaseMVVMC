//
//  LoadUsersForSearchBackendOperation.swift
//  Instagram_Firebase
//
//  Created by iosDev on 10/22/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

import Foundation

class LoadUsersForSearchBackendOperation: BaseBackendOperation {
    private let searchProvider: SearchProvider
    private let fileDownloader: FileDownloader
    private let namePart: String
    private let limit: UInt
    private(set) var downloadedUsersWithProfileImages: [UserWithProfileImage]?
    
    private enum InternalError: Error {
        case usersFetchError
    }
    
    init(searchProvider: SearchProvider, fileDownloader: FileDownloader, namePart: String, limit: UInt) {
        self.fileDownloader = fileDownloader
        self.searchProvider = searchProvider
        self.namePart = namePart
        self.limit = limit
        super.init()
    }
    
    override func start() {
        searchProvider.fetchUsersList(byNamePart: namePart,
                                      excludingUsers: .current,
                                      limit: limit,
                                      isCaseSensitive: false) { [weak self] (users) in
                                        guard let users = users else {
                                            self?.operationResult = .error(InternalError.usersFetchError)
                                            self?.finish()
                                            return
                                        }
                                        
                                        self?.fileDownloader.downloadProfileImagesForUsers(users: users, completionHandler: { (err, usersWithProfileImages) in
                                            defer {
                                                self?.finish()
                                            }
                                            guard err == nil, let usersWithProfileImages = usersWithProfileImages else {
                                                self?.operationResult = .error(err)
                                                return
                                            }
                                            self?.downloadedUsersWithProfileImages = usersWithProfileImages
                                            self?.operationResult = .success
                                        })
        }
    }
}
