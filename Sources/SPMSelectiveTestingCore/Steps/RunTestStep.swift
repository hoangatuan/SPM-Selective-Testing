//
//  File 2.swift
//  
//
//  Created by Tuan Hoang Anh on 11/5/24.
//

import Foundation
import ShellOut

struct RunTest: SelectiveTestingStep {
    
    let generator: TestPlanGeneratorProtocol.Type
    init(generator: TestPlanGeneratorProtocol.Type = TestPlanGenerator.self) {
        self.generator = generator
    }
    
    func run(with state: SelectiveTestingState) throws -> SelectiveTestingState.Change {
        guard let testPlan = state.updatedTestPlan else {
            throw SelectiveTestingError.dataProcessingError(message: "Should parse test plan first")
        }
        
        if testPlan.enabledModules.isEmpty {
            return .none
        }
        
        let startDate = Date()
        logTestTargets(state: state, updatedTestPlan: testPlan)
        try shellOut(to: "xcodebuild", arguments: state.configuration?.testCommandArguments ?? [])
        
        let endDate = Date()
        let duration = DateInterval(
            start: startDate,
            end: endDate
        ).duration
        
        log(message: "Test successfully in \(duration) seconds!!! ✅", color: .green)
        
        return .none
    }
    
    private func logTestTargets(state: SelectiveTestingState, updatedTestPlan: TestPlanModel) {
        for testTarget in unaffectedTestTarget(state: state) {
            log(message: "Skip running test target: \(testTarget). ⏭️", color: .yellow)
        }
        
        let enabledTargets = updatedTestPlan.enabledModules.map(\.target.name)
        log(message: "Start testing for: \(enabledTargets)...", color: .yellow)
        
    }
    
    private func unaffectedTestTarget(state: SelectiveTestingState) -> [String] {
        guard let originTestPlan = state.originTestPlan, let updatedTestPlan = state.updatedTestPlan else { return [] }
        let originTestTargets = originTestPlan.enabledModules.map(\.target.name)
        let updatedTestTargets = updatedTestPlan.enabledModules.map(\.target.name)
        return originTestTargets.filter { !updatedTestTargets.contains($0) }
    }
}
