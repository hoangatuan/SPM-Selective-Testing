//
//  File.swift
//  
//
//  Created by Tuan Hoang Anh on 11/5/24.
//

import Foundation
import Yams
import ShellOut

protocol TestDetectorStep {
    func run(with state: TestDetectorState) throws -> TestDetectorState.Change
}
