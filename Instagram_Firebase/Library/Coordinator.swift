//
//  Coordinator.swift
//  Instagram_Firebase
//
//  Created by iosDev on 9/21/20.
//  Copyright © 2020 iosDev. All rights reserved.
//
import UIKit.UINavigationController
protocol Coordinator {
  func start()
}

protocol NavControllerCoordinator {
    var navController: UINavigationController { get }
}
