//
//  File.swift
//  
//
//  Created by Tuan Hoang Anh on 11/5/24.
//

import Foundation

protocol SelectiveTestingStep {
    func run(with state: SelectiveTestingState) throws -> SelectiveTestingState.Change
}

extension SelectiveTestingStep {
    var description: String {
        return String(describing: Self.self)
    }
    
    func runWithTimeMeasurement(with state: SelectiveTestingState) throws -> SelectiveTestingState.Change {
        log(message: "Start running step: \(description)... ")
        let startDate = Date()
        let change = try run(with: state)
        let endDate = Date()
        let duration = DateInterval(
            start: startDate,
            end: endDate
        ).duration
        let formattedDuration = String(format: "%.3f", duration)
        log(message: "✅ Step \(description) run successfully in \(formattedDuration) seconds!!!", color: .green)
        return change
    }
}
