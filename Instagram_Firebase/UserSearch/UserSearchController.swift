//
//  UserSeachController.swift
//  Instagram_Firebase
//
//  Created by iosDev on 7/24/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

import UIKit
import Firebase

import RxSwift
import RxCocoa

class UserSearchController: UICollectionViewController {
    
    private let disposeBag = DisposeBag()
    private let cellId = "cellId"
    private var usersInfo = [UserWithProfileImage]()
    
    private var viewModel: UserSearchViewModel
    
    init(collectionViewLayout layout: UICollectionViewLayout, viewModel: UserSearchViewModel) {
        self.viewModel = viewModel
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let searchBar: UISearchBar = {
        let seachBar = UISearchBar()
        seachBar.placeholder = "Enter Username"
        seachBar.barTintColor = .gray
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        return seachBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = .white
        
        navigationController?.navigationBar.addSubview(searchBar)
        searchBar.anchor(top: navigationController?.navigationBar.topAnchor, left: navigationController?.navigationBar.leftAnchor, bottom: navigationController?.navigationBar.bottomAnchor, right: navigationController?.navigationBar.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        
        collectionView.register(UserSeachCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag
        searchBar.delegate = self
        bindUI()
    }
    
    private func bindUI() {
        
        viewModel.outputUsers.subscribe(onNext: { [weak self] (users) in
            self?.usersInfo = users
            DispatchQueue.main.async { [weak self] in
                self?.collectionView.reloadData()
            }
            }).disposed(by: disposeBag)
        
        searchBar.rx.searchButtonClicked.bind(to: self.viewModel.searchButtonClicked).disposed(by: disposeBag)
        searchBar.rx.text.changed.bind(to: self.viewModel.textDidChange).disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchBar.resignFirstResponder()
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = usersInfo[indexPath.item].user
        viewModel.userSelected.accept(user)
        searchBar.isHidden = true
//        navigationController?.navigationItem.title = ""
    }
    
    
    
    //MARK: - DataSource
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserSeachCell
        let userInfo = usersInfo[indexPath.item]
        cell.usernameLabel.text = userInfo.user.name
        cell.profileImageView.image = userInfo.profileImage
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return usersInfo.count
    }
    
}

extension UserSearchController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 66)
    }
}

extension UserSearchController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
