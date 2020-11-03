//
//  MainTabBarController.swift
//  Instagram_Firebase
//
//  Created by iosDev on 7/8/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

}

extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let index = viewControllers?.firstIndex(of: viewController),
            index == 2 {
            
            let photoSelectorController = PhotoSelectorContoller(collectionViewLayout: UICollectionViewFlowLayout())
            let navController = UINavigationController(rootViewController: photoSelectorController)
            
            presentInFullScreen(navController, animated: true)
            return false
        }
        return true
    }
}
