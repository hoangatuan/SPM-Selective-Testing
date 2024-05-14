//
//  File.swift
//  
//
//  Created by Tuan Hoang Anh on 11/5/24.
//

import Foundation

struct ModulesResolverStep: SelectiveTestingStep {
    let resolver: ModulesResolverProtocol.Type
    init(resolver: ModulesResolverProtocol.Type = ModulesResolver.self) {
        self.resolver = resolver
    }
    
    func run(with state: SelectiveTestingState) async throws -> SelectiveTestingState.Change {
        let allModules = try await resolver.resolveAllModules(
            at: state.options.rootPath,
            projectPath: state.options.projectPath
        )
        return .modulesResolved(allModules)
    }
}
