//
//  File.swift
//  
//
//  Created by Tuan Hoang Anh on 7/5/24.
//

import Foundation

struct Configuration {
    let testCommandArguments: [String]
    
    enum CodingKeys: String, CodingKey {
        case testCommandArguments = "arguments"
    }
}
