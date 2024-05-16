//
//  Created by Tuan Hoang Anh on 11/5/24.
//

import Foundation

public final class SelectiveTestingHandler {
    
    private let steps: [SelectiveTestingStep]
    private var state: SelectiveTestingState
    
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
    
    public func run() async throws {
        FileManager.default.changeCurrentDirectoryPath(state.options.rootPath)
        for step in steps {
            let changes = try await step.runWithTimeMeasurement(with: state)
            state.apply(changes)
        }
    }
}
