//
//  FirebaseSevice+UsernameProvider.swift
//  Instagram_Firebase
//
//  Created by iosDev on 8/18/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

import Foundation

extension FirebaseService: UsernameProvider {
    func fetchAuthorizedUsername(callback: @escaping (String) -> Void) {
        guard let uid = currentUid() else { return }
        usersRef.child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            let dict = snapshot.value as? Dictionary<String, Any>
            guard let user = User(fromDictionary: dict) else { return }
            
            callback(user.name)
        }) { (err) in
            print("username fetching error")
        }
    }
}
