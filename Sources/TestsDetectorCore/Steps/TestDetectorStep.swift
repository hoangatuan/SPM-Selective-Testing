//
//  File.swift
//  
//
//  Created by Tuan Hoang Anh on 11/5/24.
//

import Foundation

protocol TestDetectorStep {
    func run(with state: TestDetectorState) throws -> TestDetectorState.Change
}

extension TestDetectorStep {
    var description: String {
        return String(describing: Self.self)
    }
}
