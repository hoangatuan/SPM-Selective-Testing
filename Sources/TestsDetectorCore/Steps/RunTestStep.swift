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
            return .none
        }
        
        logUnaffactedTestTargets(state: state)
        try shellOut(to: "xcodebuild", arguments: state.configuration?.testCommandArguments ?? [])
        return .none
    }
    
    private func logUnaffactedTestTargets(state: TestDetectorState) {
        for testTarget in unaffectedTestTarget(state: state) {
            log(message: "Skip running test target: \(testTarget). ⏭️")
        }
    }
    
    private func unaffectedTestTarget(state: TestDetectorState) -> [String] {
        guard let originTestPlan = state.originTestPlan, let updatedTestPlan = state.updatedTestPlan else { return [] }
        let originTestTargets = originTestPlan.enabledModules.map(\.target.name)
        let updatedTestTargets = updatedTestPlan.enabledModules.map(\.target.name)
        return originTestTargets.filter { !updatedTestTargets.contains($0) }
    }
}
