//
//  MainTabBarCoordinator.swift
//  Instagram_Firebase
//
//  Created by iosDev on 9/21/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

import UIKit
import RxSwift
protocol MainTabBarCoordinatorProtocol: Coordinator {
    func setParentCoordinator(appCoordinator: AppCoordinatorProtocol)
    func showLoginController()
}

class MainTabBarCoordinator: MainTabBarCoordinatorProtocol {
    
    private let window: UIWindow
    private var mainTabBarController: MainTabBarController = MainTabBarController()
    private var parentCoordinator: AppCoordinatorProtocol?
    
    init(window: UIWindow, parentCoordinator: AppCoordinatorProtocol? = nil) {
        self.window = window
        self.parentCoordinator = parentCoordinator
        
        mainTabBarController.delegate = mainTabBarController
        
        setupViewControllers()
    }
    
    func setParentCoordinator(appCoordinator: AppCoordinatorProtocol) {
        self.parentCoordinator = appCoordinator
    }
    
    func start() {
        window.rootViewController = mainTabBarController
        window.makeKeyAndVisible()
    }
    
    func setupViewControllers() {
        
        let userProfileViewControllerCoordinator = UserProfileCoordinator(parentCoordinator: self)
        userProfileViewControllerCoordinator.start()
        let profileNavController = userProfileViewControllerCoordinator.navController
        profileNavController.tabBarItem.image = UIImage.assetImage(.profileUnselected)
        profileNavController.tabBarItem.selectedImage = UIImage.assetImage(.profileSelected)
        
//        let searchViewModel = UserSearchViewModel(searchProvider: FirebaseService())
        let searchNavController = templateNavController(rootVC: nil,
                                                       imageSelected: UIImage.assetImage(.seachSelected),
                                                       imageUnselected: UIImage.assetImage(.seachUnselected))
        let searchCoordinator = UserSearchCoordinator(navController: searchNavController)
        searchCoordinator.start()
        

        let homeFeedViewModel = HomeFeedViewModelEntity()
        let userProfileController2 = HomeController(collectionViewLayout: UICollectionViewFlowLayout(),
                                                    homeViewModel: homeFeedViewModel)
        let homeNavController = templateNavController(rootVC: userProfileController2,
                                                      imageSelected: UIImage.assetImage(.homeSelected),
                                                      imageUnselected: UIImage.assetImage(.homeUnselected))
        
        let plusNavController = templateNavController(rootVC: UIViewController(),
                                                      imageSelected: UIImage.assetImage(.plusUnselected),
                                                      imageUnselected: UIImage.assetImage(.plusUnselected))
        
//        let likeNavController = templateNavController(rootVC: UIViewController(),
//                                                      imageSelected: UIImage.assetImage(.likeSelected),
//                                                      imageUnselected: UIImage.assetImage(.likeUnselected))
        
        mainTabBarController.tabBar.tintColor = .black
        let viewControllers: [UINavigationController] = [homeNavController,
                                                         searchNavController,
                                                         plusNavController,
                                                         //likeNavController,
                                                         profileNavController]
        viewControllers.forEach { (navController) in
            navController.navigationBar.isTranslucent = false
        }
        mainTabBarController.viewControllers = viewControllers
        
        
        //modify tabBar item insets
        if let items = mainTabBarController.tabBar.items {
            for item in items {
                item.imageInsets = UIEdgeInsets(top: 10, left: 0, bottom: -10, right: 0)
            }
        }
        
        mainTabBarController.tabBar.isTranslucent = false
    }
    
    func templateNavController(rootVC: UIViewController?,
                               imageSelected: UIImage?,
                               imageUnselected: UIImage?,
                               layout: UICollectionViewLayout? = UICollectionViewFlowLayout()) -> UINavigationController {
        var navController: UINavigationController?
        
        if let rootVC = rootVC {
            navController = UINavigationController(rootViewController: rootVC)
        } else {
            navController = UINavigationController()
        }
        
        navController?.tabBarItem.image = imageUnselected
        navController?.tabBarItem.selectedImage = imageSelected
        return navController!
    }
    
    func showLoginController() {
        parentCoordinator?.coordinateToLoginCoordinator()
    }
}


