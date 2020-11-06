//
//  HomeController.swift
//  Instagram_Firebase
//
//  Created by iosDev on 7/19/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

import UIKit
import FirebaseAuth
import RxSwift

class HomeController: UICollectionViewController {
    
    private let disposeBag = DisposeBag()
    private let cellId = "cellId"
    private let postsProvider: PostsProvider? = FirebaseService()
    private var postsWithPostAndUserImages = [PostWithPostAndUserImage]()
    private var viewModel: HomeFeedViewModel
    
    init(collectionViewLayout: UICollectionViewFlowLayout, homeViewModel: HomeFeedViewModel) {
        self.viewModel = homeViewModel
        super.init(collectionViewLayout: collectionViewLayout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .white
        collectionView.register(HomePostCell.self, forCellWithReuseIdentifier: cellId)
        
        setupRefreshControl()
        
        setupNavigationViews()
        bindUI()
    }
    
    private func setupRefreshControl() {
        let refreshControl = UIRefreshControl()
        collectionView.refreshControl = refreshControl
    }
    
    private func bindUI() {
        viewModel.outputPostsObservable.subscribe(onNext: { [weak self] (postsWithPostAndUserImages) in
            self?.postsWithPostAndUserImages = postsWithPostAndUserImages
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
                self?.collectionView.refreshControl?.endRefreshing()
            }
        }).disposed(by: disposeBag)
        
        if let refreshControl = collectionView.refreshControl {
            refreshControl.rx.controlEvent(.valueChanged)
                .filter({ [weak refreshControl] () -> Bool in
                    refreshControl?.isRefreshing == true
                })
                .bind(to: self.viewModel.loadTrigger)
                .disposed(by: disposeBag)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func setupNavigationViews() {
        navigationItem.titleView = UIImageView(image: UIImage.assetImage(.logo2))
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! HomePostCell
        let postWithPostAndUserImage = postsWithPostAndUserImages[indexPath.item]
        cell.photoImageView.image = postWithPostAndUserImage.postImage
        cell.usernameLabel.text = postWithPostAndUserImage.post.user.name
        cell.setupCaptionLabelText(username: postWithPostAndUserImage.post.user.name,
                                   caption: postWithPostAndUserImage.post.text,
                                   creationDate: postWithPostAndUserImage.post.creationDate)
        cell.userProfileImageView.image = postWithPostAndUserImage.userProfileImage
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postsWithPostAndUserImages.count
    }
    
}

extension HomeController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 40 + 8 + 8 // username userprofileImageView
        height += view.frame.width
        height += 50
        height += 80
        return CGSize(width: view.frame.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
}

