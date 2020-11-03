//
//  SceneDelegate.swift
//  Instagram_Firebase
//
//  Created by iosDev on 6/12/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

//    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            let mainTabBarWindow = UIWindow(windowScene: windowScene)
            let loginWindow = UIWindow(windowScene: windowScene)
            let authStatusSevice = FirebaseService()
            let appCoordinator = AppCoordinator(mainTabBarWindow: mainTabBarWindow, loginWindow: loginWindow, authStatusService: authStatusSevice)
            appCoordinator.start()
        }
    }
}
