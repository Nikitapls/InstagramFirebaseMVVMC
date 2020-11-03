//
//  SavePostService.swift
//  Instagram_Firebase
//
//  Created by iosDev on 7/29/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

import UIKit

protocol SavePostService {
    func savePost(image: UIImage?, postText: String?, creationDate: Date, completionHandler: ((Error?) -> Void)?)
}
