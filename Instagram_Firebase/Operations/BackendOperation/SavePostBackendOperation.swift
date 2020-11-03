//
//  SavePostBackendOperation.swift
//  Instagram_Firebase
//
//  Created by iosDev on 10/21/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

import UIKit.UIImage



class SavePostBackendOperation: BaseBackendOperation {
    
    private let image: UIImage?
    private let postText: String?
    private let creationDate: Date
    private let savePostService: SavePostService
    
    init(image: UIImage?, postText: String?, creationDate: Date, savePostService: SavePostService) {
        self.image = image
        self.postText = postText
        self.creationDate = creationDate
        self.savePostService = savePostService
        super.init()
    }
    
    override func start() {
        savePostService.savePost(image: image, postText: postText, creationDate: creationDate) { [weak self] error in
            defer {
                self?.finish()
            }
            if error == nil {
                self?.operationResult = .success
            } else {
                self?.operationResult = .error(error)
            }
        }
    }
}
