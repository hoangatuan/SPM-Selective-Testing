//
//  Created by Tuan Hoang Anh on 11/5/24.
//

import Foundation


struct DiscoverAffectedTargetsStep: TestDetectorStep {
    
    func run(with state: TestDetectorState) throws -> TestDetectorState.Change {
        guard let testPlan = state.originTestPlan else {
            throw TestDetectorError.dataProcessingError(message: "Should parse test plan first")
        }
        
        guard let cache = state.currentCached else {
            throw TestDetectorError.dataProcessingError(message: "Should fetch cache first")
        }
        
        let enabledModules = testPlan.enabledModules.map(\.target.name)
        let enabledModulesHashes = state.modulesHashes.filter { enabledModules.contains($0.key) }
        
        let affectedTestTargets = try getAffectedTestTargets(
            from: enabledModulesHashes,
            currentModuleHashes: cache,
            allModules: state.allModules
        )
        
        if cache.isEmpty {
            log(message: "Not found any cache. Run all the test targets!", color: .yellow)
        } else {
            log(message: "Affected test targets: \(affectedTestTargets.map(\.name))", color: .yellow)
        }
        
        return .affectedTestTargetsDiscovered(affectedTestTargets)
    }
    
    private func getAffectedTestTargets(
        from testModuleHashes: [String: MD5Hash],
        currentModuleHashes: [String: MD5Hash],
        allModules: [IModule]
    ) throws -> [IModule] {
        
        let allTestModules = allModules.filter { $0.isTest }
        let allTestModulesDict = allTestModules.dictionary
        
        var testModules: [IModule] = []
        testModuleHashes.forEach { (key, value) in
            guard let module = allTestModulesDict[key] else { return }
            
            if let currentHash = currentModuleHashes[key] {
                if currentHash != value {
                    testModules.append(module)
                }
            } else {
                testModules.append(module)
            }
        }
        
        return testModules
    }
}
