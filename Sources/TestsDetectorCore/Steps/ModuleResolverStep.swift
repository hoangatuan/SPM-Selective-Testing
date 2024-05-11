//
//  File.swift
//  
//
//  Created by Tuan Hoang Anh on 11/5/24.
//

import Foundation

struct ModulesResolverStep: TestDetectorStep {
    let resolver: ModulesResolverProtocol.Type
    init(resolver: ModulesResolverProtocol.Type = ModulesResolver.self) {
        self.resolver = resolver
    }
    
    func run(with state: TestDetectorState) throws -> TestDetectorState.Change {
        let allModules = try resolver.resolveAllModules(
            at: state.options.rootPath,
            projectPath: state.options.projectPath
        )
        return .modulesResolved(allModules)
    }
}
