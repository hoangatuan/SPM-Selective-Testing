//
//  File.swift
//  
//
//  Created by Tuan Hoang Anh on 11/5/24.
//

import Foundation
import Yams

struct LoadConfigurationStep: SelectiveTestingStep {
    
    let fileManager: FileManager
    
    init(fileManager: FileManager = FileManager.default) {
        self.fileManager = fileManager
    }
    
    func run(with state: SelectiveTestingState) throws -> SelectiveTestingState.Change {
        log(message: "Try to load configuration at \(state.options.configurationPath)...")
        guard let data = fileManager.contents(atPath: state.options.configurationPath) else {
            throw SelectiveTestingError.configurationNotFound
        }
        
        do {
            let configuration = try YAMLDecoder().decode(SelectiveTestingConfiguration.self, from: data)
            return .configurationLoaded(configuration)
        } catch {
            throw SelectiveTestingError.configurationInvalid
        }
    }
}
