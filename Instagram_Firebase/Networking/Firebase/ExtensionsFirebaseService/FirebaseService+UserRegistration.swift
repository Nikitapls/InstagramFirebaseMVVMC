//
//  FirebaseService+UserRegistration.swift
//  Instagram_Firebase
//
//  Created by iosDev on 8/18/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

import Foundation
import FirebaseAuth

extension FirebaseService: UserRegistration {
    func registerUser(username: String, email: String, password: String, profilePhoto: UIImage?, completion: ((Error?) -> Void)?) {
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { [weak self] (authDataResult: AuthDataResult?, error: Error?) in
            
            guard error == nil, let uid = authDataResult?.user.uid  else {
                completion?(error)
                return
            }
            
            self?.uploadFile(data: profilePhoto?.jpegData(compressionQuality: 0.3),
                             filename: UUID().uuidString,
                             directoryPath: StorageDirectoryPath.profileImageDirectory, caseError: nil, callback: { [weak self, uid] (url) in
                                
                                let user = User(uid: uid, name: username, photoUrlString: url.absoluteString)
                                self?.usersRef.child(uid)
                                    .updateChildValues(user.dictionary, withCompletionBlock: { (err, ref) in
                                        if let err = err {
                                            print("save to db error",err.localizedDescription)
                                            completion?(err)
                                            return
                                        }
                                        completion?(nil)
                                    })
            })
        })
    }
}
