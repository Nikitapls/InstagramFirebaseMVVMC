//
//  FirebaseService+FollowingProvider.swift
//  Instagram_Firebase
//
//  Created by iosDev on 8/18/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

import Foundation

extension FirebaseService: FollowingProvider {
    
    func followUser(followingUser: User, completionHandler: @escaping ((Error?) -> Void)) {
        guard let currentUid = currentUid() else { return }
        let values = [followingUser.uid: 1]
        followingRef.child(currentUid).updateChildValues(values) { (err, ref) in
            if let err = err {
                completionHandler(err)
            }
            completionHandler(nil)
        }
    }
    
    func unfollowUser(followingUser: User, completionHandler: @escaping ((Error?) -> Void)) {
        guard let currentUid = currentUid() else { return }
        followingRef.child(currentUid).child(followingUser.uid).removeValue { (err, ref) in
            if let err = err {
                completionHandler(err)
            }
            completionHandler(nil)
        }
    }
    
    func isCurrentUserSubcribedTo(user: User, completionHandler: @escaping ((Bool, Error?) -> Void)) {
        guard let currentId = currentUid() else { return }
        followingRef.child(currentId).child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let value = snapshot.value as? NSNumber else {
                completionHandler(false, nil)
                return
            }
            let answer = Bool(truncating: value)
            completionHandler(answer, nil)
        }) { (err) in
            completionHandler(false, err)
        }
    }
}
