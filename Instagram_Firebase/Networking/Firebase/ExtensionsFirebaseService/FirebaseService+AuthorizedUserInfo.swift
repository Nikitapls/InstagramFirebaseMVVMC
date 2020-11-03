//
//  Firebase+AuthorizedUserInfo.swift
//  Instagram_Firebase
//
//  Created by iosDev on 8/18/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

import Foundation

extension FirebaseService: AuthorizedUserInfo {
    func authorizedUserUid() -> String? {
        return currentUid()
    }
    
    func fetchAuthorizedUser(callback: @escaping (User?) -> Void) {
        guard let uid = currentUid() else {
            callback(nil)
            return
        }
        usersRef.child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            let dict = snapshot.value as? Dictionary<String, Any>
            guard let user = User(fromDictionary: dict) else {
                print("error fetching user")
                callback(nil)
                return
            }
            callback(user)
        }) { (err) in
            callback(nil)
            print("username fetching error")
        }
    }
}
