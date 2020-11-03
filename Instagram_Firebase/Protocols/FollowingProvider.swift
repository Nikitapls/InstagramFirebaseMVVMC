//
//  FollowingProvider.swift
//  Instagram_Firebase
//
//  Created by iosDev on 8/18/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

import Foundation

protocol FollowingProvider {
    func followUser(followingUser: User, completionHandler: @escaping ((Error?) -> Void))
    func unfollowUser(followingUser: User, completionHandler: @escaping ((Error?) -> Void))
    func isCurrentUserSubcribedTo(user: User, completionHandler: @escaping ((Bool, Error?) -> Void))
}
