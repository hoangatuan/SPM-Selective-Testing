import ArgumentParser
import Foundation
import ShellOut

@main
struct TestsDetector: ParsableCommand {

    static let configuration = CommandConfiguration(
        commandName: "testsdetector",
        abstract: "This program will check for the tests that are really need to be executed"
    )

    #if DEBUG
    private var projectPath: String = "/Users/tuanhoang/Documents/TestDetector/iMovie"
    #else
    @Option(name: .shortAndLong, help: "The path to .xcproject or .xcworkspace")
    private var projectPath: String
    #endif

    func run() throws {

        // Step 1: Get file changes
        FileManager.default.changeCurrentDirectoryPath(projectPath)
        let filePaths = try FilePathExtractor.extractFilePaths()

        // Step2: Generate target dependencies

        print("end")
    }

}
