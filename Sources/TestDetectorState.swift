//
//  File.swift
//  
//
//  Created by Tuan Hoang Anh on 11/5/24.
//

import Foundation

struct RunOptions {
    let rootPath: String
    let projectPath: String
    let configurationPath: String
    let testPlanPath: String
}

final class TestDetectorState {
    var options: RunOptions
    var configuration: Configuration?
    var allModules: [IModule] = []
    var originTestPlan: TestPlanModel?
    var updatedTestPlan: TestPlanModel?
    var currentCached: Cache?
    var modulesHashes: [ModuleName: MD5Hash] = [:]
    var affectedTestTargets: [IModule] = []
    
    init(options: RunOptions) {
        self.options = options
    }
}

extension TestDetectorState {
    enum Change {
        case configurationLoaded(Configuration)
        case modulesResolved([IModule])
        case testPlanParsed(TestPlanModel)
        case cacheFetched(Cache)
        case hashesCalculated([ModuleName: MD5Hash])
        case affectedTestTargetsDiscovered([IModule])
        case testPlanUpdated(TestPlanModel)
        case none
    }
}

extension TestDetectorState {
    func apply(_ change: Change) {
        switch change {
        case .configurationLoaded(let configuration):
            self.configuration = configuration
        case .modulesResolved(let allModules):
            self.allModules = allModules
        case .testPlanParsed(let testPlanModel):
            self.originTestPlan = testPlanModel
        case .cacheFetched(let cache):
            self.currentCached = cache
        case .hashesCalculated(let modulesHashes):
            self.modulesHashes = modulesHashes
        case .affectedTestTargetsDiscovered(let affectedTestTargets):
            self.affectedTestTargets = affectedTestTargets
        case .testPlanUpdated(let testPlanModel):
            self.updatedTestPlan = testPlanModel
        case .none:
            return
        }
    }
}
