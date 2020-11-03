//
//  PostWithPostImage.swift
//  Instagram_Firebase
//
//  Created by iosDev on 10/2/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

import UIKit.UIImage
struct PostWithPostImage {
    let post: Post
    let postImage: UIImage?
    
    init(post: Post, postImage: UIImage?) {
        self.post = post
        self.postImage = postImage
    }
    
    init?(post: Post?, postImage: UIImage?) {
        if let post = post {
            self.init(post: post, postImage: postImage)
        } else {
            return nil
        }
    }
}
