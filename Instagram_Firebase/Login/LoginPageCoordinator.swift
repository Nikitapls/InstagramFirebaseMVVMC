//
//  LoginPageCoordinator.swift
//  Instagram_Firebase
//
//  Created by iosDev on 9/22/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

import UIKit.UIWindow

protocol LoginPageCoordinatorProtocol: Coordinator, NavControllerCoordinator {
    func showSignUpController()
    func coordinateToMainTabBarCoordinator()
    func setParentCoordinator(appCoordinator: AppCoordinatorProtocol)
}

class LoginPageCoordinator: LoginPageCoordinatorProtocol {
    func setParentCoordinator(appCoordinator: AppCoordinatorProtocol) {
        self.parentCoordinator = appCoordinator
    }
    
    var navController: UINavigationController { return loginNavController }
    
    private let window: UIWindow
    private var loginNavController: UINavigationController = UINavigationController()
    private var parentCoordinator: AppCoordinatorProtocol?
    
    init(window: UIWindow, parentCoordinator: AppCoordinatorProtocol? = nil) {
        self.window = window
        self.parentCoordinator = parentCoordinator        
    }
    
    func start() {
        let loginViewController = LoginController(viewModel: LoginPageViewModel(coordinator: self))
        loginNavController.pushViewController(loginViewController, animated: true)
        window.rootViewController = loginNavController
        window.makeKeyAndVisible()
    }
    
    func showSignUpController() {
        let signUpController = SignUpController()
        signUpController.setCoordinator(coordinator: self)
        loginNavController.navigationBar.barStyle = .default
        loginNavController.pushViewController(signUpController, animated: true)
    }
    
    func coordinateToMainTabBarCoordinator() {
        parentCoordinator?.coordinateToMainTabBarCoordinator()
    }
    
}
