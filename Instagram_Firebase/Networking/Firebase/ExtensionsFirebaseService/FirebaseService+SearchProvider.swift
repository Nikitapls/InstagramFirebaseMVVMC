//
//  FirebaseService+SearchProvider.swift
//  Instagram_Firebase
//
//  Created by iosDev on 8/18/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

import Foundation
import FirebaseDatabase

extension FirebaseService: SearchProvider {
    
    func removeUsersObservers() {
        usersRef.removeAllObservers()
    }
    
    func fetchUsersList(byNamePart namePart: String,
                        excludingUsers: ExcludedUsers,
                        limit: UInt?,
                        isCaseSensitive: Bool,
                        callback: (([User]?) -> Void)?) {
        
        let query: DatabaseQuery?
        if let limit = limit {
            query = usersRef.queryLimited(toLast: limit)
        } else {
            query = usersRef
        }
        query?.queryOrdered(byChild: User.Fields.name.rawValue)
            .queryStarting(atValue: namePart)
            .observe(.value) { [weak self] (snapshot) in
                guard let usersDictionary = snapshot.value as? Dictionary<String, Dictionary<String, Any>>
                    else { return }
                var users: [User]? = usersDictionary.compactMap { (userInfo) -> User? in
                    return User(fromDictionary: userInfo.value)
                }
                
                users = self?.filterUsers(namePart: namePart,
                                          users: users,
                                          isCaseSensitive: isCaseSensitive,
                                          excludingUsers: excludingUsers)
                
                callback?(users)
        }
    }
    
    
    fileprivate func filterUsers(namePart: String,
                                 users: [User]?,
                                 isCaseSensitive: Bool,
                                 excludingUsers: ExcludedUsers) -> [User]? {
        var filteredUsers: [User]? = users
        if namePart.count > 0 {
            if isCaseSensitive {
                filteredUsers = filteredUsers?.filter { (user) -> Bool in
                    user.name.contains(namePart)
                }
            } else {
                filteredUsers = filteredUsers?.filter { (user) -> Bool in
                    user.name.lowercased().contains(namePart.lowercased())
                }
            }
        }
        
        switch excludingUsers {
        case .current:
            guard let currentUid = currentUid() else { return filteredUsers }
            filteredUsers = filteredUsers?.filter({ (user) -> Bool in
                return user.uid != currentUid
            })
        case .users(let usersToExclude):
            filteredUsers = filteredUsers?.filter({ (user) -> Bool in
                return !usersToExclude.contains(user)
            })
        default:
            return filteredUsers
        }
        return filteredUsers
    }
}
