//
//  UsersProvider.swift
//  Instagram_Firebase
//
//  Created by iosDev on 8/4/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

import Foundation

protocol SearchProvider {
    func fetchUsersList(byNamePart namePart: String,
                        excludingUsers: ExcludedUsers,
                        limit: UInt?,
                        isCaseSensitive: Bool,
                        callback: (([User]?) -> Void)?)
    func removeUsersObservers()
}
enum ExcludedUsers {
    case current
    case users(_ users: [User])
    case none
}
