
// https://github.com/atakankarsli/xctestplanner

import Foundation

class TestPlanGenerator {
    static func readTestPlan(filePath: String) throws -> TestPlanModel {
        let url = URL(fileURLWithPath: filePath)
        let data = try Data(contentsOf: url)
        
        let decoder = JSONDecoder()
        return try decoder.decode(TestPlanModel.self, from: data)
    }
    
    static func writeTestPlan(_ testPlan: TestPlanModel, filePath: String) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let updatedData = try encoder.encode(testPlan)
        
        let url = URL(fileURLWithPath: filePath)
        try updatedData.write(to: url)
    }
    
    static func updateTestPlanTargets(testPlan: inout TestPlanModel, affectedTargets: Set<String>) {
        testPlan.testTargets = testPlan.testTargets.map { testTarget in
            let isEnabled = affectedTargets.contains(testTarget.target.name)
            return TestTarget(
                parallelizable: testTarget.parallelizable,
                skippedTests: testTarget.skippedTests,
                selectedTests: testTarget.selectedTests,
                target: testTarget.target,
                enabled: isEnabled
            )
        }
    }
}
