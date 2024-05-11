//
//  File.swift
//  
//
//  Created by Tuan Hoang Anh on 11/5/24.
//

import Foundation

struct UpdateCache: TestDetectorStep {
    let cacheServiceFactory: CacheServiceFactoryProtocol.Type
    init(cacheServiceFactory: CacheServiceFactoryProtocol.Type = CacheServiceFactory.self) {
        self.cacheServiceFactory = cacheServiceFactory
    }
    func run(with state: TestDetectorState) throws -> TestDetectorState.Change {
        guard let configuration = state.configuration else {
            throw TestDetectorError.dataProcessingError(message: "Should load configuration first")
        }
        
        guard let testPlan = state.originTestPlan else {
            throw TestDetectorError.dataProcessingError(message: "Should parse test plan first")
        }
        
        let enabledTargets = testPlan.enabledModules.map(\.target.name)
        let enabledTargetHashes = state.modulesHashes.filter { enabledTargets.contains($0.key) }
        
        // To update
        let branch = try GitUtil.getCurrentBranch()
        
        let cacheService = cacheServiceFactory.makeCacheService(
            cacheConfig: configuration.cacheConfiguration,
            branch: branch
        )
        
        try cacheService.update(with: enabledTargetHashes)
        return .none
    }
}
