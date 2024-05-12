//
//  File.swift
//  
//
//  Created by Tuan Hoang Anh on 11/5/24.
//

import Foundation

struct UpdateCache: SelectiveTestingStep {
    
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
        
        guard let testPlan = state.originTestPlan else {
            throw SelectiveTestingError.dataProcessingError(message: "Should parse test plan first")
        }
        
        let enabledTargets = testPlan.enabledModules.map(\.target.name)
        let enabledTargetHashes = state.modulesHashes.filter { enabledTargets.contains($0.key) }
        
        let branch = try gitUtil.getCurrentBranch(at: state.options.rootPath)
        
        let cacheService = cacheServiceFactory.makeCacheService(
            cacheConfig: configuration.cacheConfiguration,
            branch: branch
        )
        
        try cacheService.update(with: enabledTargetHashes)
        log(message: "Cache has been updated. Cache file url: \(cacheService.cacheFileURL.absoluteString)", color: .green)
        return .none
    }
}
