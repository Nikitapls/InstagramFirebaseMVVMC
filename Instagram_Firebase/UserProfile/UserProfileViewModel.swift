//
//  UserProfileViewModel.swift
//  Instagram_Firebase
//
//  Created by iosDev on 9/16/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

import RxSwift
import RxCocoa

class UserProfileViewModel {
    
    private enum MyError: Error {
        case fetchUserError(String)
    }
    
    enum UserType: Equatable {
        case current
        case user(User)
    }
    
    private let disposeBag = DisposeBag()
    private let backendQueue: OperationQueue = OperationQueue()
    private let dbQueue: OperationQueue = OperationQueue()
    typealias AuthorizationService = AuthorizedUserInfo & LogOutService & CurrentUIDProvider
    
    private let fileDownloader: FileDownloader = FileDownloaderEntity()
    private let authorizationService: AuthorizationService = FirebaseService()
    private let postsProvider: PostsProvider = FirebaseService()
    private let followingProvider: FollowingProvider = FirebaseService()
    private let dbProvider: LoadFromDatabaseProvider & SaveToDatabaseProvider = RealmService(currentUIDProvider: FirebaseService())
    
    private let coordinator: UserProfileCoordinator?
    
    private var currentUserType: UserType?
    private var userStatus: UserStatus?
    private var userWithProfileImage: UserWithProfileImage?
    private var postsWithPostImages = [PostWithPostImage]()
    
    // MARK: - Inputs
    let userInput = PublishRelay<UserType>()
    let logOutButtonClicked = PublishRelay<Void>()
    let editProfileFollowButtonClicked = PublishRelay<Void>()
    let loadTrigger = PublishRelay<Void>()
    // MARK: - Outputs

    let currentUser = PublishRelay<UserWithProfileImage>()
    let currentUserStatus = PublishRelay<UserStatus>()
    let outputPosts = BehaviorRelay<[PostWithPostImage]>(value: [])
    
    init(coordinator: UserProfileCoordinator?) {
        self.coordinator = coordinator
        setupBindings()
    }
    
    func setupBindings() {
        createUserInputSubcription()
        createLogOutButtonTapSubcription()
        createEditProfileButtonTapSubcription()
        
        loadTrigger.subscribe(onNext: { [weak self] () in
            guard let self = self, let userType = self.currentUserType else { return }
            let fetchUserIfNeededBackendOperation = self.createLoadUserProfileInfoFromBackendOperation(userType: userType)
            self.backendQueue.addOperation(fetchUserIfNeededBackendOperation)
        }).disposed(by: disposeBag)
    }
    
    private func createUserInputSubcription() {
        userInput.subscribe(onNext: { [weak self] (userType) in
            guard let self = self else { return }
            self.currentUserType = userType
            let dbOperation = self.loadAndAcceptUserProfileDBOperation(userType: userType)
            self.dbQueue.addOperation(dbOperation)
            
            let fetchUserIfNeededBackendOperation = self.createLoadUserProfileInfoFromBackendOperation(userType: userType)
            self.backendQueue.addOperation(fetchUserIfNeededBackendOperation)
        }).disposed(by: disposeBag)
    }
    
    private func createDownloadUserImageOperation(user: User) -> DownloadUserProfileImageBackendOperation {
        let op = DownloadUserProfileImageBackendOperation(user: user, fileDownloader: fileDownloader)
        op.completionBlock = {  [weak self] in
            guard let self = self else { return }
            switch op.operationResult {
            case .success:
                guard let userWithProfileImage = op.userWithProfileImage else { return }
                self.userWithProfileImage = userWithProfileImage
                self.currentUser.accept(userWithProfileImage)
            case.error(let error):
                print(error ?? "downloadUserImageError")
            }
        }
        return op
    }
    
    private func createLoadUserProfileInfoFromBackendOperation(userType: UserType) -> FetchUserIfNeededBackendOperation {
        let fetchUserIfNeededBackendOperation = FetchUserIfNeededBackendOperation(userType: userType,
                                                                                  authorizedUserInfo: self.authorizationService)
        fetchUserIfNeededBackendOperation.completionBlock = { [weak self] in
            guard let self = self else { return }
            switch fetchUserIfNeededBackendOperation.operationResult {
            case .success:
                guard let user = fetchUserIfNeededBackendOperation.user else { return }
                let createAndAcceptUserWithProfileImageOperation = self.createDownloadUserImageOperation(user: user)
                let createAndAcceptUserStatusOperation = self.createAndAcceptUserStatusOperation(user: user, userType: userType)
                let downloadAndAcceptPostsOperation = self.createFetchAndAcceptPostsWithPostImagesOperation(user: user)
                self.backendQueue.addOperations([createAndAcceptUserWithProfileImageOperation,
                                                  createAndAcceptUserStatusOperation,
                                                  downloadAndAcceptPostsOperation], waitUntilFinished: false)
            case .error(let error):
                print(error ?? "fetchUserIfNeededError")
            }}
        return fetchUserIfNeededBackendOperation
    }
    
    private func createAndAcceptUserStatusOperation(user: User, userType: UserType) -> CreateUserStatusBackendOperation {
        let op = CreateUserStatusBackendOperation(userType: userType, user: user, followingProvider: followingProvider)
        op.completionBlock = { [weak self] in
            guard let self = self else { return }
            switch op.operationResult {
            case .success:
                guard let userStatus = op.createdUserStatus else { return }
                self.userStatus = userStatus
                self.currentUserStatus.accept(userStatus)
            case.error(let error):
                print(error ?? "CreateUserStatusError")
            }
        }
        return op
    }
    
    private func createFetchAndAcceptPostsWithPostImagesOperation(user: User) -> FetchPostsBackendOperation {
        let op = FetchPostsBackendOperation(fileDownloader: fileDownloader, destination: .userProfileFeed(user), postsProvider: postsProvider)
        op.completionBlock = { [weak self] in
        guard let self = self else { return }
            switch op.operationResult {
            case .success:
                guard let posts = op.downloadedPosts, let postsDictionary = op.postsDictionary else { return }
                self.postsWithPostImages = posts
                self.outputPosts.accept(posts)
                
                let savePostsOperation = SavePostsWithPostImageDBOperation(saveToDBProvider: self.dbProvider, save: postsDictionary)
                self.dbQueue.addOperation(savePostsOperation)
            case.error(let error):
                print(error ?? "downloadUserImageError")
            }
        }
        return op
    }
    
    private func loadAndAcceptUserProfileDBOperation(userType: UserType) -> LoadUserProfileInfoDBOperation {
        let op = LoadUserProfileInfoDBOperation(currentUIDProvider: authorizationService,
                                                userType: userType,
                                                loadFromDBProvider: dbProvider)
        op.completionBlock = {
            switch op.operationResult {
            case .success:
                if let user = op.userWithProfileImage {
                    self.currentUser.accept(user)
                }
                self.outputPosts.accept(op.posts)
            case .error(let error):
                print(error ?? "LoadAndAcceptUserProfileDBOperationError")
            }
        }
        return op
    }
    
    func createLogOutButtonTapSubcription() {
        logOutButtonClicked.subscribe(onNext: { [weak self] () in
            let logOutHandler: () -> Void = { [weak self] in
                self?.authorizationService.logOut()
                self?.coordinator?.showLoginController()
            }
            
            let cancelHandler: () -> Void = { [weak self] in
                self?.coordinator?.dismissAlertViewController()
            }
            
            self?.coordinator?.presentAlertController(logOutHandler: logOutHandler, cancelHandler: cancelHandler)
        }).disposed(by: disposeBag)
    }
    
    private func createEditProfileButtonTapSubcription() {
        editProfileFollowButtonClicked.subscribe(onNext: { [weak self] () in
            guard let userStatus = self?.userStatus, let user = self?.userWithProfileImage?.user else { return }
            
            switch userStatus {
            case .following:
                self?.followingProvider.unfollowUser(followingUser: user) { [weak self] err in
                    guard err == nil else { return }
                    let newUserStatus = UserStatus.unfollowing
                    self?.userStatus = newUserStatus
                    self?.currentUserStatus.accept(newUserStatus)
                }
            case .unfollowing:
                self?.followingProvider.followUser(followingUser: user) { [weak self] err in
                    guard err == nil else { return }
                    let newUserStatus = UserStatus.following
                    self?.userStatus = newUserStatus
                    self?.currentUserStatus.accept(newUserStatus)
                }
            case .current:
                print("editProfileButtonTap")
            }
        }).disposed(by: disposeBag)
    }

}


