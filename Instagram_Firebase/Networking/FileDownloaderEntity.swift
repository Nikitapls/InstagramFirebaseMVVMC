//
//  ImageDownloader.swift
//  Instagram_Firebase
//
//  Created by iosDev on 7/8/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

import Foundation
import UIKit.UIImage

class FileDownloaderEntity: FileDownloader {
    
    private enum InternalError: Error {
        case loadingPostsImagesError
        case loadingUsersImagesError
    }
    
    let queue = DispatchQueue.global(qos: .userInitiated)
    
    func downloadFile(url: URL, callback: @escaping (Data?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            var outputData: Data?
            defer {
                callback(outputData)
            }
            if let err = error {
                print("fileDownloadError \(err)")
                return
            }
            guard let response = response as? HTTPURLResponse,
                (200..<300).contains(response.statusCode) else { return }
            outputData = data
        }
        queue.async {
            task.resume()
        }
    }
    
    func downloadPostImagesForPosts(posts: [Post], completionHandler: @escaping ((Error?, [PostWithPostImage]?) -> Void)) {
        var postsProfileImages: [UIImage?] = Array.init(repeating: nil, count: posts.count)
        let group = DispatchGroup()
        group.enter()
        posts.enumerated().forEach { [weak self] (offset: Int, post: Post) in
            let photoUrlString = post.imageUrl
            if let url = URL(string: photoUrlString) {
                group.enter()
                self?.downloadFile(url: url) { (data) in
                    defer { group.leave() }
                    guard let data = data,
                        let image = UIImage(data: data) else { return }
                    postsProfileImages[offset] = image
                }
            }
        }
        group.leave()
        group.notify(queue: .main) {
            let outputImages = postsProfileImages.filter { (image) -> Bool in
                image != nil
            }.map { (image) -> UIImage in
                return image!
            }
            guard outputImages.count == posts.count else {
                completionHandler(InternalError.loadingPostsImagesError, nil)
                return
            }
            let postsWithImages = posts.enumerated().map { (offset: Int, post: Post) -> PostWithPostImage in
                return PostWithPostImage(post: post, postImage: postsProfileImages[offset])
            }
            completionHandler(nil, postsWithImages)
        }
    }
    

    func downloadProfileImagesForUsers(users: [User], completionHandler: @escaping ((Error?, [UserWithProfileImage]?) -> Void)) {
        var usersProfileImages: [UIImage?] = Array.init(repeating: nil, count: users.count)
        let group = DispatchGroup()
        group.enter()
        users.enumerated().forEach { [weak self] (offset: Int, user: User) in
            if let photoUrlString = user.photoUrlString,
                let url = URL(string: photoUrlString) {
                group.enter()
                self?.downloadFile(url: url) { (data) in
                    defer { group.leave() }
                    guard let data = data,
                        let image = UIImage(data: data) else { return }
                    usersProfileImages[offset] = image
                }
            }
        }
        group.leave()
        group.notify(queue: .main) {
            let outputImages = usersProfileImages
                .filter { (image) -> Bool in
                image != nil
            }.map { (image) -> UIImage in
                return image!
            }
            guard outputImages.count == users.count else {
                completionHandler(InternalError.loadingUsersImagesError, nil)
                return
            }
            let userInfoArray = users.enumerated().map { (offset: Int, user: User) -> UserWithProfileImage in
                return UserWithProfileImage(user: user, profileImage: outputImages[offset])
            }
            completionHandler(nil, userInfoArray)
        }
    }
}
