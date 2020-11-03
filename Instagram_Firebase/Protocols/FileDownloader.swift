//
//  FileDownloadService.swift
//  Instagram_Firebase
//
//  Created by iosDev on 7/29/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

import Foundation

protocol FileDownloader {
    func downloadFile(url: URL, callback: @escaping (Data?) -> Void)
    func downloadPostImagesForPosts(posts: [Post],
                                    completionHandler: @escaping ((Error?, [PostWithPostImage]?) -> Void))
    func downloadProfileImagesForUsers(users: [User],
                                       completionHandler: @escaping ((Error?, [UserWithProfileImage]?) -> Void))
}
