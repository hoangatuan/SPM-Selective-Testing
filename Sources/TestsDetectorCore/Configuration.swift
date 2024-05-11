//
//  File.swift
//  
//
//  Created by Tuan Hoang Anh on 7/5/24.
//

import Foundation

struct CacheConfiguration: Codable {
    let local: String
    let remote: String?

    var isLocal: Bool {
        return remote == nil
    }
}

struct Configuration: Codable {
    let testCommandArguments: [String]
    let cacheConfiguration: CacheConfiguration

    enum CodingKeys: String, CodingKey {
        case testCommandArguments = "arguments"
        case cacheConfiguration = "cache_repo"
    }
}
