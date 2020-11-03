//
//  UserProfileCoordinator.swift
//  Instagram_Firebase
//
//  Created by iosDev on 9/23/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

import UIKit

protocol UserProfileCoordinatorProtocol: Coordinator {
    func presentAlertController(logOutHandler: @escaping () -> Void, cancelHandler: @escaping () -> Void)
    func dismissAlertViewController()
}
class UserProfileCoordinator: UserProfileCoordinatorProtocol {
    private let rootViewController: UINavigationController = UINavigationController()
    private var alertController: UIAlertController?
    private var userProfileViewController: UserProfileController?
    private let parentCoordinator: MainTabBarCoordinatorProtocol
    
    init(parentCoordinator: MainTabBarCoordinatorProtocol) {
        self.parentCoordinator = parentCoordinator
        let userProfileViewModel = UserProfileViewModel(coordinator: self)
        userProfileViewController = UserProfileController(collectionViewLayout: UICollectionViewFlowLayout(), viewModel: userProfileViewModel)
        //start downloading current user and posts
        userProfileViewModel.userInput.accept(.current)
    }
    
    func start() {
        guard let userProfileViewController = userProfileViewController else { return }
        rootViewController.pushViewController(userProfileViewController, animated: true)
    }
    
    func presentAlertController(logOutHandler: @escaping () -> Void, cancelHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive) { (_) in
            logOutHandler()
        })
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            cancelHandler()
        })
        rootViewController.viewControllers.first?.present(alertController, animated: true)
    }
    
    func showLoginController() {
        parentCoordinator.showLoginController()
    }
    
    func dismissAlertViewController() {
        if let alertController = alertController,
            alertController.isBeingPresented == true {
            alertController.dismiss(animated: true, completion: nil)
        }
    }
}

extension UserProfileCoordinator: NavControllerCoordinator {
    var navController: UINavigationController {
        return rootViewController
    }
}
