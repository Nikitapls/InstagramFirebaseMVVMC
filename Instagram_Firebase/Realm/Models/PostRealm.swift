//
//  PostRealm.swift
//  Instagram_Firebase
//
//  Created by iosDev on 10/13/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

import RealmSwift

class PostRealm: Object {
    let owner = LinkingObjects(fromType: UserRealm.self, property: "posts")
    @objc dynamic var imageRemoteUrl: String = ""
    @objc dynamic var text: String?
    @objc dynamic var imageWidth: Float = 0
    @objc dynamic var imageHeight: Float = 0
    @objc dynamic var creationDate: Date = Date()
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var imageLocalUrl: String?
    private(set) var postImage: UIImage?
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(postWithPostImage: PostWithPostImage) {
        self.init()
        self.id = postWithPostImage.post.id
        self.imageRemoteUrl = postWithPostImage.post.imageUrl
        self.text = postWithPostImage.post.text
        self.imageWidth = postWithPostImage.post.imageWidth
        self.imageHeight = postWithPostImage.post.imageHeight
        self.creationDate = postWithPostImage.post.creationDate
        self.postImage = postWithPostImage.postImage
    }
    
    convenience init(post: Post) {
        self.init()
        self.id = post.id
        self.imageRemoteUrl = post.imageUrl
        self.text = post.text
        self.imageWidth = post.imageWidth
        self.imageHeight = post.imageHeight
        self.creationDate = post.creationDate
    }
    
    enum Fields: String {
        case imageRemoteUrl
        case text
        case imageWidth
        case imageHeight
        case creationDate
        case id
        case imageLocalUrl
    }
    
    private var fieldsDictionary: [Fields: Any] {
        return [
            Fields.id: id,
            Fields.creationDate: creationDate,
            Fields.text: text ?? "",
            Fields.imageHeight: imageHeight,
            Fields.imageWidth: imageWidth,
            Fields.imageRemoteUrl: imageRemoteUrl,
            Fields.imageLocalUrl: imageLocalUrl ?? ""
        ]
    }
    
    var post: Post? {
        var postDictionary: [String: Any] = [
            Post.PostFields.imageUrl.rawValue: imageRemoteUrl,
            Post.PostFields.text.rawValue: text ?? "",
            Post.PostFields.imageWidth.rawValue: imageWidth,
            Post.PostFields.imageHeight.rawValue: imageHeight,
            Post.PostFields.creationDate.rawValue: creationDate.timeIntervalSince1970,
            Post.PostFields.id.rawValue: id
        ]
        owner.first?.fieldsDictionary(excluding: [.profileImageLocalUrl]).forEach { (pair) in
            if pair.key == "profileImageRemoteUrl" {
                postDictionary[User.Fields.photoUrlString.rawValue] = pair.value
            }
            postDictionary[pair.key] = pair.value
        }
        let post = Post(fromDictionary: postDictionary)
        return post
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
