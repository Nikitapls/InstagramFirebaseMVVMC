//
//  BaseDBOperation.swift
//  Instagram_Firebase
//
//  Created by iosDev on 11/2/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

import Foundation

class BaseDBOperation: AsyncOperation {
    enum OperationResult {
        case success
        case error(Error?)
    }
    private enum InternalError: Error {
        case defaultOperationResultValueNotChanged
    }
    var operationResult = OperationResult.error(InternalError.defaultOperationResultValueNotChanged)
}
