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
    private var cachePath = "/TestsCache"
    
#else
    @Option(name: .shortAndLong, help: "The path to .xcproject or .xcworkspace")
    private var projectPath: String
#endif
    
    private var fileManager: FileManager { FileManager.default }
    private let filename = "TestsCache.json"
    
    func run() throws {
        FileManager.default.changeCurrentDirectoryPath(rootPath)
        
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
        
        // Generate module hashes
        let moduleHashes = try moduleHasher.generateHash()
        
        // Find changed test targets
        let testTargets = try getChangedTestTargets(from: moduleHashes, allModules: allModules)
        
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
    
    private func getChangedTestTargets(from moduleHashes: [String: MD5Hash], allModules: [IModule]) throws -> [IModule] {
        let directoryURL = URL(fileURLWithPath: fileManager.currentDirectoryPath)
        let cacheURL = directoryURL.appendingPathComponent(cachePath)
        try fileManager.createDirectory(at: cacheURL, withIntermediateDirectories: true)
        let cacheFileURL = cacheURL.appendingPathComponent(filename)
        
        if fileManager.fileExists(atPath: cacheFileURL.path()) {
            let currentHashesJsonString = try String(contentsOf: cacheFileURL)
            guard let currentHashesJsonData = currentHashesJsonString.data(using: .utf8) else { return [] }
            
            let currentModuleHashes = try JSONSerialization.jsonObject(with: currentHashesJsonData, options: []) as? [String: MD5Hash] ?? [:]
            
            var testModules: [IModule] = []
            let allModulesDic = allModules.dictionary
            
            moduleHashes.forEach { (key, value) in
                if let currentHash = currentModuleHashes[key], currentHash != value {
                    if let module = allModulesDic[key], module.isTest {
                        testModules.append(module)
                    }
                }
            }
            
            try fileManager.removeItem(at: cacheURL)
            let jsonData = try JSONSerialization.data(withJSONObject: moduleHashes, options: .prettyPrinted)
            try jsonData.write(to: cacheURL)
            
            return testModules
        } else {
            let jsonData = try JSONSerialization.data(withJSONObject: moduleHashes, options: .prettyPrinted)
            try jsonData.write(to: cacheFileURL)
            let allTestModules = allModules.filter { $0.isTest }
            return allTestModules
        }
    }
}

