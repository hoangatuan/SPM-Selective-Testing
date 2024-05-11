//
//  File.swift
//  
//
//  Created by Tuan Hoang Anh on 4/5/24.
//

import CryptoKit
import Foundation

protocol ContentHashing {
    func hash(_ data: Data) throws -> String
    func hash(_ string: String) throws -> String
    func hash(_ strings: [String]) throws -> String
}

class ContentHasher: ContentHashing {
    func hash(_ data: Data) -> String {
        Insecure.MD5.hash(data: data)
            .compactMap { String(format: "%02x", $0) }.joined()
    }
    
    func hash(_ string: String) throws -> String {
        guard let data = string.data(using: .utf8) else {
            throw ContentHashingError.stringHashingFailed(string)
        }
        return hash(data)
    }
    
    func hash(_ strings: [String]) throws -> String {
        try hash(strings.joined())
    }
}
