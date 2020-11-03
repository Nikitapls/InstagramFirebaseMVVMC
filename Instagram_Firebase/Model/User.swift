//
//  User.swift
//  Instagram_Firebase
//
//  Created by iosDev on 7/16/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

import Foundation

public struct User: Equatable, Hashable {
    
    let uid: String
    let name: String
    let photoUrlString: String?
    
    var dictionary: [String: Any] {
        return [
            Fields.uid.rawValue: uid,
            Fields.name.rawValue: name,
            Fields.photoUrlString.rawValue: photoUrlString ?? ""
        ]
    }
    
    enum Fields: String {
        case uid
        case name
        case photoUrlString
    }
    
    init(uid: String, name: String, photoUrlString: String) {
        self.uid = uid
        self.name = name
        self.photoUrlString = photoUrlString
    }
    
    init?(fromDictionary dict: [String: Any]?) {
        guard let dict = dict else { return nil }
        
        guard let name = dict[Fields.name.rawValue] as? String,
            let uid = dict[Fields.uid.rawValue] as? String,
        let profilePhotoUrl = dict[Fields.photoUrlString.rawValue] as? String else { return nil }
        self.uid = uid
        self.name = name
        self.photoUrlString = profilePhotoUrl
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(uid)
        hasher.combine(name)
        hasher.combine(photoUrlString)
    }
}

