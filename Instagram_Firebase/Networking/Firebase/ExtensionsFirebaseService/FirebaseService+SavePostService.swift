//
//  Firebase+SavePostService.swift
//  Instagram_Firebase
//
//  Created by iosDev on 8/18/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

import UIKit

extension FirebaseService: SavePostService {
    func savePostInfoToFirebase(imageUrl: String, postText: String?, imageWidth: Float, imageHeight: Float, creationDate: Date, completionHandler: ((Error?) -> Void)?) {
        guard let uid = currentUid() else { return }
        fetchAuthorizedUser { [weak self] (user) in
            guard let user = user else { return }
            let post = Post(user: user,
                            imageUrl: imageUrl,
                            text: postText,
                            imageWidth: imageWidth,
                            imageHeight: imageHeight,
                            creationDate: creationDate)
            
            self?.postsRef.child(uid).childByAutoId().updateChildValues(post.dictionary) { (err, ref) in
                if let err = err {
                    completionHandler?(err)
                    return
                }
                completionHandler?(nil)
            }
        }
    }
    
    func savePost(image: UIImage?, postText: String?, creationDate: Date, completionHandler: ((Error?) -> Void)?) {
        guard let image = image else { return }
        guard let uploadData = image.jpegData(compressionQuality: 0.3) else { return }
        
        let filename = UUID().uuidString
        
        uploadFile(data: uploadData, filename: filename, directoryPath: .postsDirectory, caseError: completionHandler) { [weak self] (url) in
            self?.savePostInfoToFirebase(imageUrl: url.absoluteString,
                                         postText: postText,
                                         imageWidth: Float(image.size.width),
                                         imageHeight: Float(image.size.height),
                                         creationDate: creationDate,
                                         completionHandler: completionHandler)
        }
    }
}
