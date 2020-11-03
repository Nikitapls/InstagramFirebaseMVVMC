//
//  BaseBackendOperation.swift
//  Instagram_Firebase
//
//  Created by iosDev on 10/22/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

import Foundation



class BaseBackendOperation: AsyncOperation {
    enum BackendOperationResult {
        case success
        case error(Error?)
    }
    private enum InternalError: Error {
        case defaultOperationResultValueNotChanged
    }
    var operationResult = BackendOperationResult.error(InternalError.defaultOperationResultValueNotChanged)
}
