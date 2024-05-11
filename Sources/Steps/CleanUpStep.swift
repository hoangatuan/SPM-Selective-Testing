//
//  File.swift
//  
//
//  Created by Tuan Hoang Anh on 11/5/24.
//

import Foundation

struct CleanUpStep: TestDetectorStep {
    let generator: TestPlanGeneratorProtocol.Type
    init(generator: TestPlanGeneratorProtocol.Type = TestPlanGenerator.self) {
        self.generator = generator
    }
    
    func run(with state: TestDetectorState) throws -> TestDetectorState.Change {
        guard let testPlan = state.originTestPlan else {
            throw TestDetectorError.dataProcessingError(message: "Should parse test plan first")
        }
        
        try generator.writeTestPlan(testPlan, filePath: state.options.testPlanPath)
        
        return .none
    }
}
