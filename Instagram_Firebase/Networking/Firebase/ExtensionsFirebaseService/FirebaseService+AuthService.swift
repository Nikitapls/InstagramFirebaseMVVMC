//
//  Firebase+AuthService.swift
//  Instagram_Firebase
//
//  Created by iosDev on 8/18/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

import Foundation
import FirebaseAuth

extension FirebaseService: AuthenticationService, CurrentUIDProvider {
    
    func currentUid() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    func loggedInStatus() -> Bool {
        return Auth.auth().currentUser != nil
    }
    
    func logOut() {
        do {
            try Auth.auth().signOut()
        } catch let err as NSError {
            print(err.localizedDescription)
        }
    }
    
    func signIn(email: String, password: String, callback: @escaping (Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [callback] (authResult, error) in
            
            if error != nil {
                callback(false)
            }
            
            if (authResult?.user) != nil {
                callback(true)
            }
        }
    }
}
