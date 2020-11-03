//
//  FetchPostsBackendOperation.swift
//  Instagram_Firebase
//
//  Created by iosDev on 11/1/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

import Foundation

class FetchPostsBackendOperation: BaseBackendOperation {
    private let fileDownloader: FileDownloader
    private let destination: PostsDestination
    private let postsProvider: PostsProvider
    private(set) var postsDictionary: [FirebaseService.RemoteUID : [PostWithPostImage]]?
    private(set) var downloadedPosts: [PostWithPostImage]?
    private enum InternalError: Error {
        case postsDictionaryIsNil
    }
    
    init(fileDownloader: FileDownloader, destination: PostsDestination, postsProvider: PostsProvider) {
        self.fileDownloader = fileDownloader
        self.destination = destination
        self.postsProvider = postsProvider
        super.init()
    }
    
    override func start() {
        postsProvider.fetchPostsWithPostsImages(for: destination, fileDownloader: fileDownloader, completionHandler: { (error, postsDictionary) in
            defer {
                self.finish()
            }
            guard error == nil else {
                self.operationResult = .error(error)
                return
            }
            
            guard let postsDictionary = postsDictionary else {
                self.operationResult = .error(InternalError.postsDictionaryIsNil)
                return
            }
            var postsWithImages = [PostWithPostImage]()
            postsDictionary.forEach { (arg0) in
                let (_, value) = arg0
                postsWithImages.append(contentsOf: value)
            }
            postsWithImages = postsWithImages.sortedByCreationDate(order: .orderedDescending)
            self.postsDictionary = postsDictionary
            self.downloadedPosts = postsWithImages
            self.operationResult = .success
        })
    }
}
