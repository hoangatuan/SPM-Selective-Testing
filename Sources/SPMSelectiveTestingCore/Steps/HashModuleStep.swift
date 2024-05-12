//
//  File.swift
//  
//
//  Created by Tuan Hoang Anh on 11/5/24.
//

import Foundation

struct HashModulesStep: SelectiveTestingStep {
    func run(with state: SelectiveTestingState) throws -> SelectiveTestingState.Change {
        let hasher = ModuleHasher(modules: state.allModules)
        let hashes = try hasher.generateHash()
        return .hashesCalculated(hashes)
    }
}
