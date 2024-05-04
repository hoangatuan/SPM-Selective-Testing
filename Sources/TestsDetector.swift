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
    private var rootPath: String = "/Users/tuanhoang/Documents/TestsDetector/iMovie"
    private var projectPath: String = "/Users/tuanhoang/Documents/TestsDetector/iMovie/iMovie.xcodeproj"
    
    #else
    @Option(name: .shortAndLong, help: "The path to .xcproject or .xcworkspace")
    private var projectPath: String
    #endif

    private var fileManager: FileManager { FileManager.default }
    
    func run() throws {
        var allModules: [IModule] = []
        
        // Find all local modules
        let packageFiles = try! findPackageFiles()
        let modules = try packageFiles.compactMap { file -> [Module]? in
            guard let url = file.parent?.path else { return nil }
            let reader = DependenciesReader(packageRootDirectoryPath: url)
            let modules = try reader.readDependencies()
            return modules
        }.flatMap { $0 }
        
        // Find all remote modules
        let projectFileURL = URL(fileURLWithPath: projectPath)
        let projectType = try ProjectType(fileURL: projectFileURL)
        let project = try projectType.project(fileURL: projectFileURL)
        let packages: [Package] = try project.packages()
        let remoteModules = packages.map { $0.modules }.compactMap { $0 }.flatMap { $0 }
        
        allModules += modules
        allModules += remoteModules
        
        let moduleHasher = ModuleHasher(
            modules: allModules
        )
        
        try moduleHasher.generateHash()
        
        debugPrint("A")
    }
    
    private func findPackageFiles() throws -> [File] {
        var files: [File] = []
        for file in try Folder(path: rootPath).files.recursive {
            if file.name == "Package.swift" {
                files.append(file)
            }
        }
        return files
    }
}
