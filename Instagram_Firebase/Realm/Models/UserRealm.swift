//
//  UserRealm.swift
//  Instagram_Firebase
//
//  Created by iosDev on 10/13/20.
//  Copyright © 2020 iosDev. All rights reserved.
//
import RealmSwift

class UserRealm: Object {
    
    @objc dynamic var uid: String = UUID().uuidString
    @objc dynamic var name: String?
    @objc dynamic var profileImageRemoteUrl: String?
    @objc dynamic var profileImageLocalUrl: String?
    let subscribedTo = List<UserRealm>()
    let posts = List<PostRealm>()
    
    override static func primaryKey() -> String? {
        return "uid"
    }
    
    private var fieldsDictionary: [Fields: Any] {
        return [.uid: uid,
                .name: name ?? "",
                .profileImageRemoteUrl: profileImageRemoteUrl ?? "",
                .profileImageLocalUrl : profileImageLocalUrl ?? ""]
    }
    
    var user: User? {
        let userDictionary: [String: Any] = [
            User.Fields.uid.rawValue: uid,
            User.Fields.name.rawValue: name ?? "",
            User.Fields.photoUrlString.rawValue: profileImageRemoteUrl ?? ""
        ]
        return User(fromDictionary: userDictionary)
    }
    
    convenience init(user: User) {
        self.init()
        self.uid = user.uid
        self.name = user.name
        self.profileImageRemoteUrl = user.photoUrlString
    }
    
    enum Fields: String {
        case uid
        case name
        case profileImageRemoteUrl
        case profileImageLocalUrl
    }
    
    func fieldsDictionary(excluding: [Fields]) -> [String: Any] {
        var fields = fieldsDictionary
        var output = [String: Any]()
        excluding.forEach { (field) in
            fields.removeValue(forKey: field)
        }
        fields.forEach { (arg0) in
            let (key, value) = arg0
            output[key.rawValue] = value
        }
        return output
    }
}
