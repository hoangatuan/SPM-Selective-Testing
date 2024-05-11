//
//  File 2.swift
//  
//
//  Created by Tuan Hoang Anh on 11/5/24.
//

import Foundation
import ShellOut

struct RunTest: TestDetectorStep {
    
    let generator: TestPlanGeneratorProtocol.Type
    init(generator: TestPlanGeneratorProtocol.Type = TestPlanGenerator.self) {
        self.generator = generator
    }
    
    func run(with state: TestDetectorState) throws -> TestDetectorState.Change {
        guard let testPlan = state.updatedTestPlan else {
            throw TestDetectorError.dataProcessingError(message: "Should parse test plan first")
        }
        
        if testPlan.enabledModules.isEmpty {
            print("No test targets need to be run")
            return .none
        }
        
        try shellOut(to: "xcodebuild", arguments: state.configuration?.testCommandArguments ?? [])
        return .none
    }
}
