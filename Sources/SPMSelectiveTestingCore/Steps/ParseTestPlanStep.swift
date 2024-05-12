//
//  File.swift
//  
//
//  Created by Tuan Hoang Anh on 11/5/24.
//

import Foundation

struct ParseTestPlanStep: SelectiveTestingStep {
    
    let generator: TestPlanGeneratorProtocol.Type
    init(generator: TestPlanGeneratorProtocol.Type = TestPlanGenerator.self) {
        self.generator = generator
    }
    
    func run(with state: SelectiveTestingState) throws -> SelectiveTestingState.Change {
        do {
            let testPlan = try generator.readTestPlan(filePath: state.options.testPlanPath)
            return .testPlanParsed(testPlan)
        } catch {
            throw SelectiveTestingError.testPlanInvalid
        }
    }
}
