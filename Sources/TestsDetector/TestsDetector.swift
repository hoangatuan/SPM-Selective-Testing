
import ArgumentParser
import Foundation
import TestsDetectorCore

@main
struct TestsDetector: ParsableCommand {
    
    static let configuration = CommandConfiguration(
        commandName: "testsdetector",
        abstract: "This program will check for the tests that are really need to be executed"
    )
    
#if DEBUG
    private var rootPath: String = "/Users/tuanhoang/Documents/TestsDetector/iMovie"
    private var projectPath: String = "/Users/tuanhoang/Documents/TestsDetector/iMovie/iMovie.xcodeproj"
    private var testPlanPath: String = "/Users/tuanhoang/Documents/TestsDetector/iMovie/iMovie.xctestplan"
    private var configurationPath = "/Users/tuanhoang/Documents/TestsDetector/Resources/selective-testing.yml"

#else
    @Option(name: .shortAndLong, help: "The path to .xcproject or .xcworkspace")
    private var projectPath: String
#endif
    
    private var fileManager: FileManager { FileManager.default }
    
    func run() throws {
        FileManager.default.changeCurrentDirectoryPath(rootPath)
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

