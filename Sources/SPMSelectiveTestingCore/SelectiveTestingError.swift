//
//  File.swift
//  
//
//  Created by Tuan Hoang on 9/5/24.
//

import Foundation

enum SelectiveTestingError: Error {
    case configurationNotFound
    case configurationInvalid
    case testPlanInvalid
    case dataProcessingError(message: String)
}
