//
//  UserRegistration.swift
//  Instagram_Firebase
//
//  Created by iosDev on 7/29/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

import UIKit

protocol UserRegistration {
    func registerUser(username: String, email: String, password: String, profilePhoto: UIImage?, completion: ((Error?) -> Void)?)
}
