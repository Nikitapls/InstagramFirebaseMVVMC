//
//  HeaderDelegate.swift
//  Instagram_Firebase
//
//  Created by iosDev on 9/24/20.
//  Copyright © 2020 iosDev. All rights reserved.
//


import UIKit.UIImage
import UIKit.UIButton

protocol HeaderDelegate {
    func setUserStatus(userStatus: UserStatus)
    func setUserWithProfileImage(user: UserWithProfileImage)
    var editProfileFollowButton: UIButton { get }
    func clearHeader()
}
