import ArgumentParser
import Foundation
import ShellOut
import Files

@main
struct TestsDetector: ParsableCommand {

    static let configuration = CommandConfiguration(
        commandName: "testsdetector",
        abstract: "This program will check for the tests that are really need to be executed"
    )

    #if DEBUG
    private var projectPath: String = "/Users/tuanhoang/Documents/TestsDetector/iMovie"
    #else
    @Option(name: .shortAndLong, help: "The path to .xcproject or .xcworkspace")
    private var projectPath: String
    #endif

    private var fileManager: FileManager { FileManager.default }
    
    func run() throws {

//        // Step 1: Get file changes
//        FileManager.default.changeCurrentDirectoryPath(projectPath)
//        let filePaths = try FilePathExtractor.extractFilePaths()
//
//        // Step2: Generate target dependencies
//
//        print("end")
        
        let packageFiles = try! findPackageFiles()
        let modules = try packageFiles.compactMap { file -> [Module]? in
            guard let url = file.parent?.path else { return nil }
            let reader = DependenciesReader(packageRootDirectoryPath: url)
            let modules = try reader.readDependencies()
            return modules
        }.flatMap { $0 }
        
        let sourceCodes = modules[0].sourceCodes
        // Next: Hash all the information
        
        debugPrint("A")
    }
    
    private func findPackageFiles() throws -> [File] {
        var files: [File] = []
        for file in try Folder(path: projectPath).files.recursive {
            if file.name == "Package.swift" {
                files.append(file)
            }
        }
        return files
    }

//    private func convert(from modules: [[Module]]) -> [UpdatedModule] {
//        var dic: [String: UpdatedModule] = [:]
//        let flattenModules = modules.flatMap { $0 }.forEach {
//            dic[$0.name] = UpdatedModule(name: $0.name, dependencies: [])
//        }
//        
//        var results: [UpdatedModule] = []
//        
//        return results
//    }
}
