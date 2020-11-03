//
//  FirebaseService+PostsProvider.swift
//  Instagram_Firebase
//
//  Created by iosDev on 8/18/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

import Foundation

extension FirebaseService {
    typealias RemoteUID = String
    fileprivate enum UserType {
        case currentUser
        case user(_ user: User?)
        case userUid(_ uid: String?)
    }
}

extension FirebaseService: PostsProvider {
    func fetchPosts(for destination: PostsDestination, completionHandler: @escaping (Error?, [RemoteUID : [Post]]?) -> Void) {
        switch destination {
        case .userProfileFeed(let user):
            let uid = user.uid
            fetchExistingPosts(uid: uid, completionHandler: { (error, inputDictionary) in
                guard error == nil, let inputDictionary = inputDictionary else {
                    completionHandler(error, nil)
                    return
                }
                let uid = inputDictionary.0
                let postsDictionary = inputDictionary.1
                completionHandler(nil, [uid: postsDictionary])
            })
        case .homeFeed:
            fetchPostsForHomeFeed(completionHandler: completionHandler)
        }
    }
    
    func fetchPostsWithPostsImages(for destination: PostsDestination,
                                   fileDownloader: FileDownloader,
                                   completionHandler: @escaping (Error?, [RemoteUID : [PostWithPostImage]]?) -> Void) {
        fetchPosts(for: destination) { (error, postsDict) in
            guard error == nil, let postsDict = postsDict else {
                completionHandler(error, nil)
                return
            }
            var resultDictionary = [String : [PostWithPostImage]]()
            let group = DispatchGroup()
            postsDict.forEach { (arg0) in
                let (uid, posts) = arg0
                group.enter()
                fileDownloader.downloadPostImagesForPosts(posts: posts) { (error, postsWithPostImage) in
                    defer { group.leave() }
                    guard error == nil, let posts = postsWithPostImage else {
                        print(error ?? "err")
                        return
                    }
                    resultDictionary[uid] = posts
                }
            }
            group.notify(queue: .global(qos: .userInitiated)) {
                completionHandler(nil, resultDictionary)
            }
        }
    }
    
    private func fetchPostsForHomeFeed (completionHandler: @escaping (Error?, [RemoteUID : [Post]]?) -> Void) {
        guard let currentUid = currentUid() else { return }
        var resultDictionary = [String : [Post]]()
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        followedUIDs { [weak self] (uidArr) in
            var usersID = uidArr
            usersID.append(currentUid)
            usersID.forEach { (uid) in
                self?.fetchExistingPosts(uid: uid, completionHandler: { (error, inputTuple) in
                    guard error == nil, let inputTuple = inputTuple else {
                        return
                    }
                    let uid = inputTuple.0
                    let postsArray = inputTuple.1
                    resultDictionary[uid] = postsArray
                }, group: dispatchGroup)
            }
            dispatchGroup.leave()
        }
        dispatchGroup.notify(queue: .main) {
            print("Home Feed post download completion handler")
            completionHandler(nil, resultDictionary)
        }
    }
    
    // returns a closure with an array with all uids the current user is subscribed to
    private func followedUIDs(followingUIDHandler: @escaping (([RemoteUID]) -> Void)) {
        guard let currentUid = currentUid() else { return }
        followingRef
            .child(currentUid)
            .observeSingleEvent(of: .value) { (snapshot) in
                guard let followingStatusDictionary = snapshot.value as? Dictionary<String, Int> else {
                    followingUIDHandler([])
                    return
                }
                let uidArray: [String] = followingStatusDictionary.map { (arg0) -> RemoteUID? in
                    let (uid, followingInt) = arg0
                    let isFollowing = Bool(truncating: followingInt as NSNumber)
                    return isFollowing ? uid : nil
                }.compactMap { $0 }
                followingUIDHandler(uidArray)
        }
    }
    
    fileprivate func fetchExistingPosts(uid: RemoteUID,
                                        completionHandler: @escaping (Error?, (RemoteUID, [Post])?) -> Void,
                                        group: DispatchGroup? = nil) {
        group?.enter()
        postsRef.child(uid)
            .queryOrdered(byChild: Post.PostFields.creationDate.rawValue)
            .observeSingleEvent(of: .value, with: { (snapshot) in
                defer {
                    group?.leave()
                }
                guard snapshot.exists() else {
                    completionHandler(nil,nil)
                    return
                }
                guard let dictionary = snapshot.value as? [String : [String : Any]] else {
                    completionHandler(ErrorType.unwrapError, nil)
                    return
                }
                
                let postsArray = dictionary.map { (arg0) -> Post? in
                    let (id, postInfo) = arg0
                    var postDict = postInfo
                    postDict[Post.PostFields.id.rawValue] = id
                    return Post(fromDictionary: postDict)
                }.compactMap { (post) -> Post? in
                    post
                }
                completionHandler(nil, (uid, postsArray))
            })
    }
    
    enum ErrorType: Error {
        case unwrapError
    }
}
