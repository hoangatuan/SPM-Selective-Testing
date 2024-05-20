//
//  File.swift
//  
//
//  Created by Tuan Hoang on 9/5/24.
//

import Foundation

public enum SelectiveTestingError: Error {
    case configurationNotFound
    case configurationInvalid
    case testPlanInvalid
    case parseLocalPackageFailed(path: String)
    case dataProcessingError(message: String)

    var localizedDescription: String {
        switch self {
        case .configurationNotFound:
            return "Configuration file not found"
        case .configurationInvalid:
            return "Configuration file is invalid"
        case .testPlanInvalid:
            return "Test plan is invalid"
        case .parseLocalPackageFailed(let path):
            return "Parse local package at \(path) failed"
        case .dataProcessingError(let message):
            return "Data processing error: \(message)"
        }
    }
}
