//
//  Protocols.swift
//  Instagram_Firebase
//
//  Created by iosDev on 7/8/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

protocol AuthorizedUserInfo {
    func fetchAuthorizedUser(callback: @escaping (User?) -> Void)
    func authorizedUserUid() -> String? 
}

