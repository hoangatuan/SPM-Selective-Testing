//
//  File.swift
//  
//
//  Created by Tuan Hoang on 9/5/24.
//

import Foundation

enum TestDetectorError: Error {
    case configurationNotFound
    case configurationInvalid
    case testPlanInvalid
    case dataProcessingError(message: String)
}
