//
//  UsernameProvider.swift
//  Instagram_Firebase
//
//  Created by iosDev on 7/29/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

protocol UsernameProvider {
    func fetchAuthorizedUsername(callback: @escaping (String) -> Void)
}
