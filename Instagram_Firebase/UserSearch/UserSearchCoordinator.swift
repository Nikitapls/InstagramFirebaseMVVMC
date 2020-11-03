//
//  UserSearchCoordinator.swift
//  Instagram_Firebase
//
//  Created by iosDev on 10/8/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

import UIKit.UIViewController

protocol UserSearchCoordinatorProtocol: Coordinator, NavControllerCoordinator {
    func presentUserProfileController(for user: User)
}

class UserSearchCoordinator: UserSearchCoordinatorProtocol {

    let navController: UINavigationController
    let userProfileController: UserProfileController
    let searchVC: UserSearchController
    
    init(navController: UINavigationController) {
        self.navController = navController
        
        let userProfileViewModel = UserProfileViewModel(coordinator: nil)
        userProfileController = UserProfileController(collectionViewLayout: UICollectionViewFlowLayout(),
                                                      viewModel: userProfileViewModel)
        
        let searchViewModel = UserSearchViewModel(searchProvider: FirebaseService())
        searchVC = UserSearchController(collectionViewLayout: UICollectionViewFlowLayout(),
                                        viewModel: searchViewModel)
        searchViewModel.setCoordinator(coordinator: self)
    }
    
    func start() {
        navController.pushViewController(searchVC, animated: true)
    }
    
    func presentUserProfileController(for user: User) {
        userProfileController.setUser(user: user)
        navController.pushViewController(userProfileController, animated: true)
    }

}
