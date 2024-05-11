//
//  File.swift
//  
//
//  Created by Tuan Hoang Anh on 11/5/24.
//

import Foundation

protocol CacheServiceFactoryProtocol {
    static func makeCacheService(cacheConfig: CacheConfiguration, branch: String) -> CacheServiceProtocol
}

enum CacheServiceFactory: CacheServiceFactoryProtocol {
    static func makeCacheService(cacheConfig: CacheConfiguration, branch: String) -> CacheServiceProtocol {
        if cacheConfig.isLocal {
            return LocalCacheService(branch: branch, localPath: cacheConfig.local)
        } else {
            let remote = URL(string: cacheConfig.remote!)!
            return RemoteCacheService(remote: remote, localPath: cacheConfig.local, branch: branch)
        }
    }
}
