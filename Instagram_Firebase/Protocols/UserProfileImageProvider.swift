//
//  UserProfileImageProvider.swift
//  Instagram_Firebase
//
//  Created by iosDev on 7/29/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

import UIKit

protocol UserProfileImageProvider {
    func userProfileImage(fileDownloader: FileDownloader, callback: @escaping (UIImage?) -> Void)
}
