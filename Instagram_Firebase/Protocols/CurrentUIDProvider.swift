//
//  CurrentUIDProvider.swift
//  Instagram_Firebase
//
//  Created by iosDev on 10/28/20.
//  Copyright © 2020 iosDev. All rights reserved.
//
import Foundation
protocol CurrentUIDProvider {
    func currentUid() -> String?
}
