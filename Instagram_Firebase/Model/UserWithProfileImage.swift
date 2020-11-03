//
//  UserWithProfileImage.swift
//  Instagram_Firebase
//
//  Created by iosDev on 10/2/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

import Foundation
import UIKit.UIImage

struct UserWithProfileImage: Hashable {
    let user: User
    let profileImage: UIImage?
    
    init(user: User, profileImage: UIImage?) {
        self.user = user
        self.profileImage = profileImage
    }
    
    init?(user: User?, profileImage: UIImage?) {
        if let user = user {
            self.init(user: user, profileImage: profileImage)
        } else {
            return nil
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(user)
    }
}

