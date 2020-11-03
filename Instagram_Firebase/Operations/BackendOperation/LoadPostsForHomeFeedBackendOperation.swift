//
//  Instagram_Firebase
//
//  Created by iosDev on 10/21/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

import Foundation

class LoadPostsForHomeFeedBackendOperation: BaseBackendOperation {
    private let postsProvider: PostsProvider
    private let fileDownloader: FileDownloader
    private(set) var loadedPosts: [PostWithPostAndUserImage]?
    private enum InternalError: Error {
        case errorFetchingPostsWithPostImages
        case errorFetchingUserImages
    }
    
    init(postsProvider: PostsProvider, fileDownloader: FileDownloader) {
        self.postsProvider = postsProvider
        self.fileDownloader = fileDownloader
        super.init()
    }
    
    override func start() {
        fetchPostsWithImages { [weak self] (err, postsWithPostImages) in
            guard err == nil, let postsWithPostImages = postsWithPostImages else {
                self?.operationResult = .error(InternalError.errorFetchingPostsWithPostImages)
                self?.finish()
                return
            }
            self?.downloadUserImages(for: postsWithPostImages) { (error, postsWithPostAndUserImages) in
                defer {
                    self?.finish()
                }
                guard err == nil, let postsWithPostAndUserImages = postsWithPostAndUserImages else {
                    self?.operationResult = .error(InternalError.errorFetchingUserImages)
                    return
                }
                let sortedPosts = postsWithPostAndUserImages.sortedByCreationDate(order: .orderedDescending)
                self?.loadedPosts = sortedPosts
                self?.operationResult = .success
            }
        }
    }
    
    private func fetchPostsWithImages(completionHandler: @escaping (Error?, [PostWithPostImage]?) -> Void) {
        postsProvider.fetchPostsWithPostsImages(for: .homeFeed, fileDownloader: fileDownloader) { (error, postsDictonary) in
            guard error == nil else {
                completionHandler(error, nil)
                return
            }
            var posts = [PostWithPostImage]()
            postsDictonary?.forEach({ (arg0) in
                let (_, value) = arg0
                posts.append(contentsOf: value)
            })
            completionHandler(nil, posts)
        }
    }
    
    private func downloadUserImages(for postsWithPostImages: [PostWithPostImage],
                                    completionHandler: @escaping (Error?, [PostWithPostAndUserImage]?) -> Void) {
        let users = postsWithPostImages.map { (postWithPostImage) -> User in
            return postWithPostImage.post.user
        }
        fileDownloader.downloadProfileImagesForUsers(users: users) { (error, usersWithProfileImages) in
            guard error == nil, let usersWithProfileImages = usersWithProfileImages else {
                completionHandler(error, nil)
                return
            }
            let postsWithPostAndUserImage = usersWithProfileImages
                .enumerated()
                .map { (offset: Int, userWithProfileImage: UserWithProfileImage) -> PostWithPostAndUserImage in
                    let postWithPostImage = postsWithPostImages[offset]
                    return PostWithPostAndUserImage(post: postWithPostImage.post,
                                                    postImage: postWithPostImage.postImage,
                                                    userProfileImage: userWithProfileImage.profileImage)
            }
            
            completionHandler(nil, postsWithPostAndUserImage)
        }
    }
}
