//
//  Database.swift
//  Instagram_Firebase
//
//  Created by iosDev on 10/14/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

// problem with image duplicating on disk. when more then 1 thread call save(postsDict:) with the same posts at the same time
//(db works fine, but some images are saved twice)
// toDo: 1) refactor func save(postsDict: [FirebaseService.RemoteUID: [PostWithPostImage]]) to work with save(post), save(user) instead of realmDictonary with difficult logic
// 2) save UserRealm.subscribedTo property when its possible
// 3) clear users not being followed by the current user and clear cache

import RealmSwift

protocol SaveToDatabaseProvider {
    func save(info: [PostWithPostAndUserImage]) throws
    func save(dict: [FirebaseService.RemoteUID : [PostWithPostImage]]) throws
}

protocol LoadFromDatabaseProvider {
    func load(uid: String?, completionHandler: @escaping (Error?, [UserWithProfileImage: [PostWithPostImage]]?) -> Void)
    func loadPostsForHomeFeed(completionHandler: @escaping (Error?, [UserWithProfileImage: [PostWithPostImage]]?) -> Void) throws
    func loadUsers(completionHandler: (Error?, [UserWithProfileImage]?) -> Void)
}


class RealmService {
    
    let operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        return queue
    }()
    
    
    private enum RealmServiceInternalErrors: Error {
        case inputUidIsNil
        case unwrapError
        case currentUidIsNil
    }
    
    private let currentUIDProvider: CurrentUIDProvider
    
    init(currentUIDProvider: CurrentUIDProvider) {
        self.currentUIDProvider = currentUIDProvider
    }
    
    private func clearLocalStorage() {
        fatalError("not implemented")
    }
}

// MARK: - SaveToDatabaseProvider
extension RealmService: SaveToDatabaseProvider {
    private func saveUserWithProfileImage(to realm: Realm, user: User, profileImage: UIImage?) throws -> UserRealm? {
        let untrackedUserRealm = UserRealm(user: user)
        let infoToUpdate = untrackedUserRealm.fieldsDictionary(excluding: [.profileImageLocalUrl,.profileImageRemoteUrl])
        var realmUser: UserRealm?
        try realm.write {
            realmUser = realm.create(UserRealm.self, value: infoToUpdate, update: .modified)
            if realmUser?.profileImageRemoteUrl != user.photoUrlString {
                let localImageUrl = ImageSaver.save(image: profileImage)
                realmUser?.profileImageLocalUrl = localImageUrl
            } else if realmUser?.profileImageLocalUrl == nil || realmUser?.profileImageLocalUrl == "" {
                let localImageUrl = ImageSaver.save(image: profileImage)
                realmUser?.profileImageLocalUrl = localImageUrl
            }
            realmUser?.profileImageRemoteUrl = user.photoUrlString
        }
        return realmUser
    }
    
    private func saveUser(to realm: Realm, user: User) throws -> UserRealm? {
        let untrackedUserRealm = UserRealm(user: user)
        let infoToUpdate = untrackedUserRealm.fieldsDictionary(excluding: [.profileImageLocalUrl])
        var realmUser: UserRealm?
        try realm.write {
            realmUser = realm.create(UserRealm.self, value: infoToUpdate, update: .modified)
        }
        return realmUser
    }
    
    private func savePostWithPostImage(to realm: Realm, post: Post, postImage: UIImage?) throws -> PostRealm? {
        let untrackedPostRealm = PostRealm(post: post)
        let infoToUpdate = untrackedPostRealm.fieldsDictionary(excluding: [.imageLocalUrl, .imageRemoteUrl])
        var postRealm: PostRealm?
        try realm.write {
            postRealm = realm.create(PostRealm.self, value: infoToUpdate, update: .modified)
            if postRealm?.imageRemoteUrl != untrackedPostRealm.imageRemoteUrl {
                let localImageUrl = ImageSaver.save(image: postImage)
                postRealm?.imageLocalUrl = localImageUrl
                postRealm?.imageRemoteUrl = untrackedPostRealm.imageRemoteUrl
            } else if postRealm?.imageLocalUrl == nil || postRealm?.imageLocalUrl == "" {
                let localImageUrl = ImageSaver.save(image: postImage)
                postRealm?.imageLocalUrl = localImageUrl
            }
        }
        return postRealm
    }
    
    func save(info: [PostWithPostAndUserImage]) throws {
        let inputDict = transformToDictionary(input: info)
        do {
            let realm = try Realm()
            var currentUserSubscribedTo = [UserRealm]()
            
            try inputDict.forEach({ (arg0) in
                let (user, posts) = arg0
                guard let userRealm = try self.saveUserWithProfileImage(to: realm,
                                                                        user: user.user,
                                                                        profileImage: user.profileImage) else { return }
                let postsRealm = try posts.map { (post) -> PostRealm? in
                    return try self.savePostWithPostImage(to: realm, post: post.post, postImage: post.postImage)
                }.compactMap { $0 }
                
                try realm.write {
                    userRealm.posts.removeAll()
                    userRealm.posts.append(objectsIn: postsRealm)
                }
                currentUserSubscribedTo.append(userRealm)
            })
            
            if let currentUserID = currentUIDProvider.currentUid(),
                let currentUserRealm = realm.object(ofType: UserRealm.self, forPrimaryKey: currentUserID) {
                
                currentUserSubscribedTo = currentUserSubscribedTo.filter { (user) -> Bool in
                    user.uid != currentUserID
                }
                
                try realm.write {
                    currentUserRealm.subscribedTo.removeAll()
                    currentUserRealm.subscribedTo.append(objectsIn: currentUserSubscribedTo)
                }
            }
        }
    }
    
    private func transformToDictionary(input: [PostWithPostAndUserImage]) -> [UserWithProfileImage: [PostWithPostImage]] {
        typealias UID = String
        var tempDictionary = [User: [PostWithPostImage]]()
        var usersProfileImages = [UID: UIImage]()
        input.forEach {
            (postWithPostAndUserImage) in
            let user = postWithPostAndUserImage.post.user
            let post = PostWithPostImage(post: postWithPostAndUserImage.post, postImage: postWithPostAndUserImage.postImage)
            usersProfileImages[user.uid] = postWithPostAndUserImage.userProfileImage
            if tempDictionary[user] == nil {
                tempDictionary[user] = [post]
            } else {
                tempDictionary[user]?.append(post)
            }
        }
        
        var output = [UserWithProfileImage: [PostWithPostImage]]()
        tempDictionary.forEach { (arg0) in
            let (user, posts) = arg0
            let userWithProfileImage = UserWithProfileImage(user: user, profileImage: usersProfileImages[user.uid])
            output[userWithProfileImage] = posts
        }
        
        return output
    }
    
    func save(dict: [FirebaseService.RemoteUID : [PostWithPostImage]]) throws {
        var dictInCorrectForm = [User: [PostWithPostImage]]()
        dict.forEach { (arg0) in
            let (_, value) = arg0
            value.forEach { (postWithPostImage) in
                let user = postWithPostImage.post.user
                
                if dictInCorrectForm[user] == nil {
                    dictInCorrectForm[user] = []
                }
                
                dictInCorrectForm[user]?.append(postWithPostImage)
            }
        }
        
        do {
            let realm = try Realm()
            try dictInCorrectForm.forEach { (arg0) in
                let (user, postsWithPostImage) = arg0
                let userRealm = try saveUser(to: realm, user: user)
                let postsRealm = try postsWithPostImage.map { (postWithPostImage) -> PostRealm? in
                    return try savePostWithPostImage(to: realm, post: postWithPostImage.post, postImage: postWithPostImage.postImage)
                }.compactMap({ $0 })
                
                try realm.write {
                    userRealm?.posts.removeAll()
                    userRealm?.posts.append(objectsIn: postsRealm)
                }
            }
        }
    }
}

// MARK: - LoadFromDatabaseProvider

extension RealmService: LoadFromDatabaseProvider {
    
    func load(uid: String?, completionHandler: @escaping (Error?, [UserWithProfileImage: [PostWithPostImage]]?) -> Void) {
        
        guard let uid = uid else {
            completionHandler(RealmServiceInternalErrors.inputUidIsNil,nil)
            return
        }
        do {
            let realm = try Realm()
            let userRealm = realm.object(ofType: UserRealm.self, forPrimaryKey: uid)
            fetchPostsForUserRealm(userRealm: userRealm, completionHandler: completionHandler)
        } catch let error {
            completionHandler(error, nil)
        }
    }
    
    private func createUserWithProfileImage(from userRealm: UserRealm?) -> UserWithProfileImage? {
        guard let userRealm = userRealm else { return nil }
        return UserWithProfileImage(user: userRealm.user,
                                    profileImage: ImageSaver.extract(path: userRealm.profileImageLocalUrl))
    }
    
    private func fetchPostsForUserRealm(userRealm: UserRealm?,
                                        completionHandler: @escaping (Error?, [UserWithProfileImage: [PostWithPostImage]]?) -> Void) {
        let postsRealm = userRealm?.posts

        guard let userWithProfileImage = createUserWithProfileImage(from: userRealm) else {
                                                                completionHandler(RealmServiceInternalErrors.unwrapError,nil)
                                                                return
        }
        
        var posts = [PostWithPostImage?]()
        
        postsRealm?.forEach { (postRealm) in
            let post = postRealm.post
            let image = ImageSaver.extract(path: postRealm.imageLocalUrl)
            posts.append(PostWithPostImage(post: post, postImage: image))
        }
        
        let outputPosts = posts.compactMap { $0 }
        completionHandler(nil, [userWithProfileImage: outputPosts])
    }
    
    func loadPostsForHomeFeed(completionHandler: @escaping (Error?, [UserWithProfileImage: [PostWithPostImage]]?) -> Void) throws {
        guard let currentUid = currentUIDProvider.currentUid() else {
            completionHandler(RealmServiceInternalErrors.currentUidIsNil, nil)
            return
        }
        do {
            let realm = try Realm()
            guard let currentUserRealm = realm.object(ofType: UserRealm.self, forPrimaryKey: currentUid) else { return }
            
            var usersToLoadPosts = Array(currentUserRealm.subscribedTo)
            usersToLoadPosts.append(currentUserRealm)
            
            fetchPostsForUsers(users: usersToLoadPosts, completionHandler: completionHandler)
        }
        
    }
    //fetch all posts in current thread.
    // to do: concurrency
    private func fetchPostsForUsers(users: [UserRealm],
                                    completionHandler: @escaping (Error?, [UserWithProfileImage: [PostWithPostImage]]?) -> Void) {
        var fetchResult = [UserWithProfileImage: [PostWithPostImage]]()
        users.forEach { [weak self] (user) in
            self?.fetchPostsForUserRealm(userRealm: user) { (err, dict) in
                guard err == nil else {
                    completionHandler(err, nil)
                    return
                }
                
                dict?.forEach({ (key, value) in
                    fetchResult[key] = value
                })
            }
        }
        
        completionHandler(nil, fetchResult)
    }
    
    func loadUsers(completionHandler: (Error?, [UserWithProfileImage]?) -> Void) {
        do {
            let realm = try Realm()
            let users = realm.objects(UserRealm.self)
            
            let output = Array(users).map { (userRealm) -> UserWithProfileImage? in
                return createUserWithProfileImage(from: userRealm)
            }.compactMap({ $0 })
            
            completionHandler(nil, output)
        } catch let error {
            completionHandler(error, nil)
        }
    }
}

