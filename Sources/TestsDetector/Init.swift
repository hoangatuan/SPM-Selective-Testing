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
        FileManager.default.changeCurrentDirectoryPath("/Users/tuanhoang/Documents/TestsDetector/iMovie")
        let defaultConfiguration = TestSelectiveConfiguration.generateDefaultCongiruration()
         
        let directory = FileManager.default.currentDirectoryPath
        FileManager.default.createFile(
            atPath: "\(directory)/\(Constants.fileNameWithExtension)",
            contents: defaultConfiguration.asYamlData(),
            attributes: nil
        )
    }
}
