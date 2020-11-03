//
//  PostsProvider.swift
//  Instagram_Firebase
//
//  Created by iosDev on 7/29/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

import Firebase

protocol PostsProvider {
//    func fetchPosts(for destination: PostsDestination,
//        completionHandler: @escaping (Error?, [String : [Post]]?) -> Void)
    func fetchPostsWithPostsImages(for destination: PostsDestination,
                                   fileDownloader: FileDownloader,
                                   completionHandler: @escaping (Error?, [FirebaseService.RemoteUID : [PostWithPostImage]]?) -> Void)
}

enum PostsDestination {
    case homeFeed
    case userProfileFeed(User)
}



