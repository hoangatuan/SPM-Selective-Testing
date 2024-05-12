//
//  File.swift
//  
//
//  Created by Tuan Hoang Anh on 11/5/24.
//

import Foundation

struct FetchCacheStep: SelectiveTestingStep {
        
    let gitUtil: GitUtilProtocol.Type
    let cacheServiceFactory: CacheServiceFactoryProtocol.Type
    
    init(
        gitUtil: GitUtilProtocol.Type = GitUtil.self,
        cacheServiceFactory: CacheServiceFactoryProtocol.Type = CacheServiceFactory.self
    ) {
        self.gitUtil = gitUtil
        self.cacheServiceFactory = cacheServiceFactory
    }
    
    func run(with state: SelectiveTestingState) throws -> SelectiveTestingState.Change {
        guard let configuration = state.configuration else {
            throw SelectiveTestingError.dataProcessingError(message: "Should load configuration first")
        }
        
        let branch = try gitUtil.getCurrentBranch(at: state.options.rootPath)
        
        let cacheService = cacheServiceFactory.makeCacheService(
            cacheConfig: configuration.cacheConfiguration,
            branch: branch
        )
        
        let cache = try cacheService.fetch()
        return .cacheFetched(cache)
    }
}
