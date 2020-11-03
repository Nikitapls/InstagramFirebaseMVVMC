//
//  AuthenificationService.swift
//  Instagram_Firebase
//
//  Created by iosDev on 7/29/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

typealias AuthenticationService = SignInService & LogOutService & AuthStatusService

protocol SignInService {
    func signIn(email: String, password: String, callback: @escaping (Bool) -> Void)
}

protocol LogOutService {
    func logOut()
}

protocol AuthStatusService {
    func loggedInStatus() -> Bool 
}
