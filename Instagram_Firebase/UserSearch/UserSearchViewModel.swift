//
//  UserSearchViewModel.swift
//  Instagram_Firebase
//
//  Created by iosDev on 9/14/20.
//  Copyright © 2020 iosDev. All rights reserved.
//
import UIKit.UIImage
import RxSwift
import RxCocoa

protocol UserSearchViewModelProtocol {
    var textDidChange: PublishRelay<String?> { get }
    var searchButtonClicked: PublishRelay<Void> { get }
    var userSelected: PublishRelay<User> { get }
    
    var outputUsersObservable: Observable<[UserWithProfileImage]> { get }
}

class UserSearchViewModel {
    
    private let disposeBag = DisposeBag()
    private let backendQueue = OperationQueue()
    private let databaseQueue = OperationQueue()
    private var searchProvider: SearchProvider
    private var lastTextInput: String = ""
    private let fileDownloader: FileDownloader = FileDownloaderEntity()
    private var downloadedUsersWithProfileImages = [UserWithProfileImage]()
    private var coordinator: UserSearchCoordinatorProtocol?
    private let loadFromDBProvider: LoadFromDatabaseProvider = RealmService(currentUIDProvider: FirebaseService())
    // Output
    let outputUsers: BehaviorRelay<[UserWithProfileImage]> = BehaviorRelay<[UserWithProfileImage]>(value: [])
    
    // Input
    let textDidChange = PublishRelay<String?>()
    let searchButtonClicked = PublishRelay<Void>()
    let userSelected = PublishRelay<User>()
    
    init(searchProvider: SearchProvider) {
        self.searchProvider = searchProvider
        textDidChange.subscribe(onNext: { [weak self] (namePart) in
            guard let usersInfo = self?.downloadedUsersWithProfileImages,
                let namePart = namePart,
                let filteredUsers = self?.filterAndSortUsersInfo(usersInfo: usersInfo, namePart: namePart) else { return }
            
            self?.lastTextInput = namePart
            
            if namePart.count > 0 {
                self?.outputUsers.accept(filteredUsers)
            } else {
                //namePart = "", since we are not having the entire list of users, we need to fetch it again
                self?.fetchUsers(byNamePart: namePart)
            }
        }).disposed(by: disposeBag)
        

        searchButtonClicked.subscribe(onNext: { [weak self] _ in
            self?.fetchUsers(byNamePart: self?.lastTextInput)
        }).disposed(by: disposeBag)
        
        userSelected.subscribe(onNext: { [weak self] (user) in
            self?.coordinator?.presentUserProfileController(for: user)
        }).disposed(by: disposeBag)
        
        fetchUsers(byNamePart: "")
    }
    
    func setCoordinator(coordinator: UserSearchCoordinatorProtocol?) {
        self.coordinator = coordinator
    }
    
    private func fetchUsersFromRealmAndAccept() {
        RealmService(currentUIDProvider: FirebaseService()).loadUsers { (err, users) in
            guard err == nil,
                let users = users else {
                    return
            }
            downloadedUsersWithProfileImages = users
            outputUsers.accept(users)
        }
    }
    
    fileprivate func fetchUsers(byNamePart namePart: String?, limit: UInt = 100) {
        guard let namePart = namePart else { return }
        let databaseLoadOperation = loadAndAcceptUsersForSearchOperation()
        databaseQueue.addOperation(databaseLoadOperation)
        
        let backendLoadOperation = LoadUsersForSearchBackendOperation(searchProvider: searchProvider,
                                                    fileDownloader: fileDownloader,
                                                    namePart: namePart,
                                                    limit: limit)
        backendLoadOperation.completionBlock = { [weak self] in
            guard let self = self else { return }
            switch backendLoadOperation.operationResult {
            case .success:
                guard let downloadedUsers = backendLoadOperation.downloadedUsersWithProfileImages else { return }
                self.downloadedUsersWithProfileImages = downloadedUsers
                self.outputUsers.accept(downloadedUsers)
            case .error(let error):
                print(error ?? "err")
            }
        }
        
        backendQueue.addOperation(backendLoadOperation)
    }
    
    private func loadAndAcceptUsersForSearchOperation() -> LoadUsersDBOperation {
        let op = LoadUsersDBOperation(loadFromDBProvider: loadFromDBProvider)
        op.completionBlock = { [weak self] in
            guard let self = self else { return }
            switch op.operationResult {
            case .success:
                let users = op.loadedUsers
                self.downloadedUsersWithProfileImages = users
                self.outputUsers.accept(users)
            case .error(let error):
                print(error ?? "loadAndAcceptUsersForSearchOperationError")
            }
        }
        return op
    }
    
    private func filterAndSortUsersInfo(usersInfo: [UserWithProfileImage], namePart: String) -> [UserWithProfileImage] {
        var filteredUsers = [UserWithProfileImage]()
        
        if namePart.count > 0 {
            filteredUsers = usersInfo.filter({ (userInfo) -> Bool in
                userInfo.user.name.lowercased().contains(namePart.lowercased())
            })
        } else {
            filteredUsers = usersInfo
        }
        
        filteredUsers.sort { (first, second) -> Bool in
            return first.user.name.compare(second.user.name) == .orderedAscending
        }
        return filteredUsers
    }
    
}

extension UserSearchViewModel: UserSearchViewModelProtocol {
    var outputUsersObservable: Observable<[UserWithProfileImage]> {
        return outputUsers.asObservable()
    }
}
