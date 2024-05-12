//
//  File.swift
//  
//
//  Created by Tuan Hoang Anh on 11/5/24.
//

import Foundation

struct UpdateTestPlanStep: SelectiveTestingStep {
    
    let generator: TestPlanGeneratorProtocol.Type
    init(generator: TestPlanGeneratorProtocol.Type = TestPlanGenerator.self) {
        self.generator = generator
    }
    
    func run(with state: SelectiveTestingState) throws -> SelectiveTestingState.Change {
        guard let originTestPlan = state.originTestPlan else {
            throw SelectiveTestingError.dataProcessingError(message: "Should parse test plan first")
        }
        
        let updatedTestPlan = generator.updateTestPlanTargets(
            testPlan: originTestPlan,
            affectedTargets: Set(state.affectedTestTargets.map(\.name))
        )
        
        try generator.writeTestPlan(updatedTestPlan, filePath: state.options.testPlanPath)
        return .testPlanUpdated(updatedTestPlan)
    }
}
