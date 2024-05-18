//
//  File.swift
//  
//
//  Created by Tuan Hoang Anh on 18/5/24.
//

import Foundation

protocol PlatformHashing {
    func hash(module: IModule) throws -> MD5Hash
}

struct PlatformHasher: PlatformHashing {
    let contentHasher: ContentHashing
    init(contentHasher: ContentHashing = ContentHasher()) {
        self.contentHasher = contentHasher
    }
    
    func hash(module: IModule) throws -> MD5Hash {
        guard let localModule = module as? LocalModule else {
            return ""
        }
        
        var hashes: [MD5Hash] = []
        for platform in localModule.platforms {
            let platformHash = try contentHasher.hash(platform.id)
            hashes.append(platformHash)
        }
        
        let platformHash = try contentHasher.hash(hashes)
        return platformHash
    }
}
