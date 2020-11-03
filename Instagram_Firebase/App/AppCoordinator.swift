//
//  AppCoordinator.swift
//  Instagram_Firebase
//
//  Created by iosDev on 9/21/20.
//  Copyright © 2020 iosDev. All rights reserved.
//
import UIKit
import RxSwift

protocol AppCoordinatorProtocol: Coordinator {
    func coordinateToLoginCoordinator()
    func coordinateToMainTabBarCoordinator()
}

class AppCoordinator: AppCoordinatorProtocol {
    // MARK: - Properties
    private let authStatusService: AuthStatusService
    private let mainTabBarCoordinator: MainTabBarCoordinatorProtocol
    private let loginPageCoordinator: LoginPageCoordinatorProtocol
    
    // MARK: - Coordinator
    
    init(mainTabBarWindow: UIWindow, loginWindow: UIWindow, authStatusService: AuthStatusService) {
        self.authStatusService = authStatusService
        mainTabBarCoordinator = MainTabBarCoordinator(window: mainTabBarWindow)
        loginPageCoordinator = LoginPageCoordinator(window: loginWindow)
        mainTabBarCoordinator.setParentCoordinator(appCoordinator: self)
        loginPageCoordinator.setParentCoordinator(appCoordinator: self)
    }

    func start() {
        if authStatusService.loggedInStatus() == true {
            mainTabBarCoordinator.start()
        } else {
            loginPageCoordinator.start()
        }
    }
    
    func coordinateToLoginCoordinator() {
        loginPageCoordinator.start()
    }
    
    func coordinateToMainTabBarCoordinator() {
        mainTabBarCoordinator.start()
    }
}

