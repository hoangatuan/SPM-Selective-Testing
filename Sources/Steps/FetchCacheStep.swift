//
//  File.swift
//  
//
//  Created by Tuan Hoang Anh on 11/5/24.
//

import Foundation

struct FetchCacheStep: TestDetectorStep {
        
    let cacheServiceFactory: CacheServiceFactoryProtocol.Type
    init(cacheServiceFactory: CacheServiceFactoryProtocol.Type = CacheServiceFactory.self) {
        self.cacheServiceFactory = cacheServiceFactory
    }
    
    func run(with state: TestDetectorState) throws -> TestDetectorState.Change {
        guard let configuration = state.configuration else {
            throw TestDetectorError.dataProcessingError(message: "Should load configuration first")
        }
        
        // To update
        let branch = try GitUtil.getCurrentBranch()
        
        let cacheService = cacheServiceFactory.makeCacheService(
            cacheConfig: configuration.cacheConfiguration,
            branch: branch
        )
        
        let cache = try cacheService.fetch()
        return .cacheFetched(cache)
    }
}
