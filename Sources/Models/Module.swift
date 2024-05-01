//
//  File.swift
//  
//
//  Created by Tuan Hoang Anh on 1/5/24.
//

import Foundation

enum TargetType : String, Codable {
    case regular
    case executable
    case test
    case system
    case binary
    case plugin
    case macro
}

public struct Module {
    let name: String
    let type: TargetType
    let dependencies: [String]
    let path: String?
    let sources: [String]?
    let exclude: [String]
}
