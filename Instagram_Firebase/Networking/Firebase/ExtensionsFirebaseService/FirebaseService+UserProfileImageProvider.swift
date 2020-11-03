//
//  FirebaseService+UserProfileImageProvider.swift
//  Instagram_Firebase
//
//  Created by iosDev on 8/18/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

import Foundation
import UIKit

extension FirebaseService: UserProfileImageProvider {
    func userProfileImage(fileDownloader: FileDownloader, callback: @escaping (UIImage?) -> Void) {
        guard let uid = currentUid() else { return }
        
        usersRef.child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            let dict = snapshot.value as? Dictionary<String, Any>
            guard let user = User(fromDictionary: dict) else { return }
            
            guard let urlString = user.photoUrlString,
                let downloadUrl = URL(string: urlString) else { return }
            
            fileDownloader.downloadFile(url: downloadUrl) { [callback] (data) in
                var downloadedImage: UIImage?
                
                defer {
                    callback(downloadedImage)
                }
                
                guard let data = data else { return }
                
                downloadedImage = UIImage(data: data)
            }
        }) { (err) in
            print("username fetching error")
        }
    }
}
