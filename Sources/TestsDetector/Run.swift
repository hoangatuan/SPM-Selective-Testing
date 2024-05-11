//
//  Created by Tuan Hoang Anh on 11/5/24.
//


import ArgumentParser
import Foundation
import TestsDetectorCore

struct Run: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "run",
        abstract: "This program will check for the tests that are really need to be executed"
    )
    
#if DEBUG
    private var rootPath: String = "/Users/tuanhoang/Documents/TestsDetector/iMovie"
    private var projectPath: String = "/Users/tuanhoang/Documents/TestsDetector/iMovie/iMovie.xcodeproj"
    private var testPlanPath: String = "/Users/tuanhoang/Documents/TestsDetector/iMovie/iMovie.xctestplan"
    private var configurationPath = "/Users/tuanhoang/Documents/TestsDetector/Resources/selective-testing.yml"

#else
    @Option(name: .shortAndLong, help: "The root path of the project. If not provided, the program will use the current directory.")
    private var rootPath: String?
    
    @Argument(help: "The path to your *.xcodeproj or *.xcworkspace.")
    var projectPath: String
    
    @Option(
        name: [.customShort("c"), .customLong("configuration")],
        help: "The path to the configuration file. If not provided, the program will find the configuration file in the rootPath."
    )
    var configurationPath: String?
    
    @Argument(
        help: "The path for the test plan."
    )
    var testPlanPath: String
    
#endif
    func run() throws {
        let handler = TestsDetectorHandler(
            options: .init(
                rootPath: rootPath,
                projectPath: projectPath,
                configurationPath: configurationPath,
                testPlanPath: testPlanPath
            )
        )
        
        try handler.run()
    }
}
