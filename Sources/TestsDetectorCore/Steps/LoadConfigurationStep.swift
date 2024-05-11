//
//  File.swift
//  
//
//  Created by Tuan Hoang Anh on 11/5/24.
//

import Foundation
import Yams

struct LoadConfigurationStep: TestDetectorStep {
    
    let fileManager: FileManager
    
    init(fileManager: FileManager = FileManager()) {
        self.fileManager = fileManager
    }
    
    func run(with state: TestDetectorState) throws -> TestDetectorState.Change {
        guard let data = fileManager.contents(atPath: state.options.configurationPath) else {
            throw TestDetectorError.configurationNotFound
        }
        
        do {
            let configuration = try YAMLDecoder().decode(Configuration.self, from: data)
            return .configurationLoaded(configuration)
        } catch {
            throw TestDetectorError.configurationInvalid
        }
    }
}
