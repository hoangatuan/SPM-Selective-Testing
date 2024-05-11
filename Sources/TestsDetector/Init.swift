//
//  Created by Tuan Hoang Anh on 7/5/24.
//

import ArgumentParser
import Foundation
import TestsDetectorCore

struct Init: ParsableCommand {
    
    static let configuration = CommandConfiguration(
        commandName: "init",
        abstract: "Creates the configuration file"
    )
    
    func run() throws {
        let defaultConfiguration = TestSelectiveConfiguration.generateDefaultCongiruration()
         
        let directory = FileManager.default.currentDirectoryPath
        let configurationPath = "\(directory)/\(Constants.fileNameWithExtension)"
        FileManager.default.createFile(
            atPath: configurationPath,
            contents: defaultConfiguration.asYamlData(),
            attributes: nil
        )
        
        log(message: "📄 Configuration file has been created at \(configurationPath).", color: .green)
    }
}
