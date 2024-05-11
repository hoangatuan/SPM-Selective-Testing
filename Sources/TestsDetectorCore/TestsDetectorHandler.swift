//
//  File.swift
//  
//
//  Created by Tuan Hoang Anh on 11/5/24.
//

import Foundation

public final class TestsDetectorHandler {
    
    private let steps: [TestDetectorStep]
    private var state: TestDetectorState
    
    public init(options: RunOptions) {
        self.state = .init(options: options)
        self.steps =  [
            LoadConfigurationStep(),
            ModulesResolverStep(),
            ParseTestPlanStep(),
            FetchCacheStep(),
            HashModulesStep(),
            DiscoverAffectedTargetsStep(),
            UpdateTestPlanStep(),
            RunTest(),
            UpdateCache(),
            CleanUpStep()
        ]
    }
    
    public func run() throws {
        for step in steps {
            log(message: "Start running step: \(step.description)...")
            let changes = try step.run(with: state)
            state.apply(changes)
        }
    }
}