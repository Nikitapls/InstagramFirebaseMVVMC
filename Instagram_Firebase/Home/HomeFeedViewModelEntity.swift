//
//  HomeViewModel.swift
//  Instagram_Firebase
//
//  Created by iosDev on 9/9/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

import RxSwift
import RxCocoa

protocol HomeFeedViewModel {
    var outputPosts: BehaviorRelay<[PostWithPostAndUserImage]> { get }
    var loadTrigger: PublishSubject<Void> { get }
}

class HomeFeedViewModelEntity: HomeFeedViewModel {
    private let disposeBag = DisposeBag()
    private let backendQueue = OperationQueue()
    private let dbQueue = OperationQueue()
    private let postsProvider: PostsProvider = FirebaseService()
    private let fileDownloader: FileDownloader = FileDownloaderEntity()
    private let dbService: LoadFromDatabaseProvider & SaveToDatabaseProvider = RealmService(currentUIDProvider: FirebaseService())

    // Output
    var outputPosts: BehaviorRelay<[PostWithPostAndUserImage]> = BehaviorRelay(value: [])

    // Input
    let loadTrigger = PublishSubject<Void>()
    
    init() {
        
        loadTrigger.subscribe(onNext: { [weak self] () in
            self?.startPostsDownloading()
        }).disposed(by: disposeBag)
        
        startPostsDownloading()
    }
    
    func startPostsDownloading() {
        let loadPostsDBOperation = LoadPostsDBOperation(loadFromDBProvider: dbService)
        loadPostsDBOperation.completionBlock = {
            switch loadPostsDBOperation.operationResult {
            case .success:
                self.outputPosts.accept(loadPostsDBOperation.loadedPosts)
            case .error(let error):
                print(error ?? "LoadPostsDBOperationError")
            }
        }
        dbQueue.addOperation(loadPostsDBOperation)
        let loadPostsBackendOperation = LoadPostsForHomeFeedBackendOperation(postsProvider: postsProvider, fileDownloader: fileDownloader)
        loadPostsBackendOperation.completionBlock = { [weak self] in
            guard let self = self else { return }
            let opResult = loadPostsBackendOperation.operationResult
            switch opResult {
            case .success:
                let loadedPosts = loadPostsBackendOperation.loadedPosts ?? []
                self.outputPosts.accept(loadedPosts)
                let saveOp = SavePostsDBOperation(saveToDBProvider: self.dbService, posts: loadedPosts)
                self.dbQueue.addOperation(saveOp)
            case .error(let err):
                print(err ?? "err")
            }
        }
        backendQueue.addOperation(loadPostsBackendOperation)
    }

}
