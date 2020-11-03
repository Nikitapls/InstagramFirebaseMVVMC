//
//  LoadPostsDBOperation.swift
//  Instagram_Firebase
//
//  Created by iosDev on 11/2/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

import Foundation

class LoadPostsDBOperation: BaseDBOperation {
    private let loadFromDatabaseProvider: LoadFromDatabaseProvider
    private(set) var loadedPosts: [PostWithPostAndUserImage] = []
    
    init(loadFromDBProvider: LoadFromDatabaseProvider) {
        self.loadFromDatabaseProvider = loadFromDBProvider
    }
    
    override func start() {
        do {
            try loadFromDatabaseProvider.loadPostsForHomeFeed { [weak self] (err, dict) in
                defer { self?.finish() }
                guard err == nil, let loadedPosts = self?.translate(dict: dict) else {
                        self?.operationResult = .error(err)
                        return
                }
                self?.operationResult = .success
                self?.loadedPosts = loadedPosts.sortedByCreationDate(order: .orderedDescending)
            }
        } catch let error {
            operationResult = .error(error)
            finish()
        }
    }
    
    private func translate(dict: [UserWithProfileImage: [PostWithPostImage]]?) -> [PostWithPostAndUserImage]? {
        guard let dict = dict else { return nil }
        let output = dict.map { (arg0) -> [PostWithPostAndUserImage] in
            let (userWithProfileImage, posts) = arg0
            var postsWithPostAndUserImage = [PostWithPostAndUserImage]()
            posts.forEach { (postWithPostImage) in
                postsWithPostAndUserImage.append(PostWithPostAndUserImage(post: postWithPostImage.post,
                                                    postImage: postWithPostImage.postImage,
                                                    userProfileImage: userWithProfileImage.profileImage))
                
            }
            return postsWithPostAndUserImage
        }.flatMap { $0 }
        return output
    }
}
