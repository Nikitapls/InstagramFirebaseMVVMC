//
//  UserProfileController.swift
//  Instagram_Firebase
//
//  Created by iosDev on 7/8/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class UserProfileController: UICollectionViewController {
    
    private enum CellIds: String {
        case cellId
        case headerId
    }
    
    private let disposeBag = DisposeBag()
    private let viewModel: UserProfileViewModelProtocol
    private var userStatus: UserStatus?
    private var userWithProfileImage: UserWithProfileImage?
    private var postsWithPostImages = [PostWithPostImage]()
    
    init(collectionViewLayout layout: UICollectionViewLayout, viewModel: UserProfileViewModelProtocol) {
        self.viewModel = viewModel
        super.init(collectionViewLayout: layout)
        setupLogOutButton()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUser(user: User) {
        clearViewUI()
        self.viewModel.userInput.accept(.user(user))
    }
    
    func clearViewUI() {
        userStatus = nil
        postsWithPostImages = []
        DispatchQueue.main.async { [weak self] in
            self?.headerDelegate?.clearHeader()
            self?.navigationItem.title = ""
            self?.navigationItem.rightBarButtonItem = nil
            self?.collectionView.reloadData()
        }
    }
    
    var headerDelegate: HeaderDelegate? {
        didSet {
            if let userStatus = userStatus {
                headerDelegate?.setUserStatus(userStatus: userStatus)
                headerDelegate?.editProfileFollowButton.rx.tap
                    .bind(to: viewModel.editProfileFollowButtonClicked)
                    .disposed(by: disposeBag)
            }
            if let userWithProfileImage = userWithProfileImage {
                headerDelegate?.setUserWithProfileImage(user: userWithProfileImage)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .white
        collectionView.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CellIds.headerId.rawValue)
        collectionView.register(UserProfilePhotoCell.self, forCellWithReuseIdentifier: CellIds.cellId.rawValue)
        setupAndBindRefreshControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadTrigger.accept({}())
    }
    
    private func setupBindings() {
        viewModel.currentUserObservable.subscribe(onNext: { [weak self] (userWithProfileImage) in
            self?.userWithProfileImage = userWithProfileImage
            DispatchQueue.main.async {
                self?.navigationItem.title = userWithProfileImage.user.name
                self?.headerDelegate?.setUserWithProfileImage(user: userWithProfileImage)
            }
        }).disposed(by: disposeBag)
        
        viewModel.currentUserStatusObservable.subscribe(onNext: { [weak self] (status) in
            self?.userStatus = status
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.headerDelegate?.setUserStatus(userStatus: status)
                self.headerDelegate?.editProfileFollowButton.rx.tap
                    .bind(to: self.viewModel.editProfileFollowButtonClicked)
                    .disposed(by: self.disposeBag)
            }
        }).disposed(by: disposeBag)
        
        viewModel.outputPostsObservable.subscribe(onNext: { [weak self] (postsWithPostImages) in
            self?.postsWithPostImages = postsWithPostImages
            DispatchQueue.main.async { [weak self] in
                self?.collectionView.reloadData()
                self?.collectionView.refreshControl?.endRefreshing()
            }
        }).disposed(by: disposeBag)
    }
    
    private func setupAndBindRefreshControl() {
        let refreshControl = UIRefreshControl()
        collectionView.refreshControl = refreshControl
        if let refreshControl = collectionView.refreshControl {
            refreshControl.rx.controlEvent(.valueChanged)
                .filter({ [weak refreshControl] () -> Bool in
                    refreshControl?.isRefreshing == true
                })
                .bind(to: self.viewModel.loadTrigger)
                .disposed(by: disposeBag)
        }
    }
    
    fileprivate func setupLogOutButton() {
        let barButtonItem = UIBarButtonItem(image: UIImage.assetImage(AssetImagesNames.gear)?.withRenderingMode(.alwaysOriginal),
                                            style: .plain,
                                            target: self,
                                            action: nil)
        navigationItem.rightBarButtonItem = barButtonItem
        navigationItem.rightBarButtonItem?.rx.tap.bind(to: viewModel.logOutButtonClicked)
            .disposed(by: disposeBag)
    }
    
    //MARK: - СollcetionViewDelegateMethods
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CellIds.headerId.rawValue, for: indexPath) as! UserProfileHeader
        headerDelegate = header
        return header
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postsWithPostImages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIds.cellId.rawValue, for: indexPath) as! UserProfilePhotoCell
        cell.imageView.image = postsWithPostImages[indexPath.item].postImage
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2) / 3
        return CGSize(width: width, height: width)
    }
    
    
}

extension UserProfileController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
}
