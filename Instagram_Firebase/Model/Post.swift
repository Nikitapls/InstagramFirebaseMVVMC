//
//  Post.swift
//  Instagram_Firebase
//
//  Created by iosDev on 7/16/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

import Foundation

struct Post: Equatable {
    let user: User
    let imageUrl: String
    let text: String?
    let imageWidth: Float
    let imageHeight: Float
    let creationDate: Date
    let id: String
    
    var dictionary: [String: Any] {
        var postInfo: [String : Any] = [
            PostFields.imageUrl.rawValue: imageUrl,
            PostFields.text.rawValue: text ?? "",
            PostFields.imageWidth.rawValue: imageWidth,
            PostFields.imageHeight.rawValue: imageHeight,
            PostFields.creationDate.rawValue: creationDate.timeIntervalSince1970,
            PostFields.id.rawValue: id
            ]
        
        user.dictionary.forEach { (pair) in
            postInfo[pair.key] = pair.value
        }
        
        return postInfo
    }
    
    enum PostFields: String {
        case imageUrl
        case text
        case imageWidth
        case imageHeight
        case creationDate
        case user
        case id
    }
    
    init(user: User, id: String = UUID().uuidString, imageUrl: String, text: String?, imageWidth: Float, imageHeight: Float, creationDate: Date) {
        self.imageUrl = imageUrl
        self.text = text
        self.imageWidth = imageWidth
        self.imageHeight = imageHeight
        self.creationDate = creationDate
        self.user = user
        self.id = id
    }
    
    init?(fromDictionary dict: [String: Any]?) {
        guard let dict = dict else { return nil }
        
        guard let imageUrl = dict[PostFields.imageUrl.rawValue] as? String,
            let imageWidth = dict[PostFields.imageWidth.rawValue] as? Float,
            let imageHeight = dict[PostFields.imageHeight.rawValue] as? Float,
            let creationTime = dict[PostFields.creationDate.rawValue] as? Double,
            let id = dict[PostFields.id.rawValue] as? String,
            let user = User(fromDictionary: dict) else {
                print(dict)
                return nil }
        
        let date = Date(timeIntervalSince1970: creationTime)
        let postText = dict[PostFields.text.rawValue] as? String

        self.id = id
        self.imageUrl = imageUrl
        self.text = postText
        self.imageWidth = imageWidth
        self.imageHeight = imageHeight
        self.creationDate = date
        self.user = user
    }
}
