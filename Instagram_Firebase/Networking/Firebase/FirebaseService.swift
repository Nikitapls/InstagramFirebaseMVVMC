//
//  FirebaseService.swift
//  Instagram_Firebase
//
//  Created by iosDev on 7/6/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

import UIKit
import Firebase

enum StorageDirectoryPath: String {
    case profileImageDirectory = "UsersProfilePhoto"
    case postsDirectory = "Posts"
}

enum FirebaseKeys: String {
    case users
    case posts
    case following
}

class FirebaseService: NSObject {
    
    private(set) lazy var usersRef = Database.database().reference().child(FirebaseKeys.users.rawValue)
    private(set) lazy var postsRef = Database.database().reference().child(FirebaseKeys.posts.rawValue)
    private(set) lazy var followingRef = Database.database().reference().child(FirebaseKeys.following.rawValue)
    
}


