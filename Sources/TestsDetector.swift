import ArgumentParser
import Foundation
import ShellOut
import Files
import Yams

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
    private var cachePath = "/TestsCache"
    private var configurationPath = "/Users/tuanhoang/Documents/TestsDetector/Resources/selective-testing.yml"

#else
    @Option(name: .shortAndLong, help: "The path to .xcproject or .xcworkspace")
    private var projectPath: String
#endif
    
    private var fileManager: FileManager { FileManager.default }
    private let filename = "TestsCache.json"
    
    func run() throws {
        FileManager.default.changeCurrentDirectoryPath(rootPath)

        guard let configuration = try loadConfiguration() else {
            throw TestDetectorError.configurationNotFound
        }

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

        // Get current hashes
        let currentModuleHashes = try fetchCache(with: configuration)

        // Generate module hashes
        let moduleHashes = try moduleHasher.generateHash()
        
        // Find changed test targets
        let testTargets = try getChangedTestTargets(from: moduleHashes, currentModuleHashes: currentModuleHashes, allModules: allModules).map { $0.name }
        
        debugPrint(testTargets)
        
        // Update test plan
        var testplan = try TestPlanGenerator.readTestPlan(filePath: testPlanPath)
        TestPlanGenerator.updateTestPlanTargets(testPlan: &testplan, affectedTargets: Set(testTargets))
        try TestPlanGenerator.writeTestPlan(testplan, filePath: testPlanPath)
        debugPrint(testplan)

        // Run test
        
        try shellOut(to: "xcodebuild", arguments: configuration.testCommandArguments)
        
        // Store cache
        
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

    private func loadConfiguration() throws -> Configuration? {
        guard let data = FileManager.default.contents(atPath: configurationPath) else { return nil }

        do {
            let configuration = try YAMLDecoder().decode(Configuration.self, from: data)
            return configuration
        } catch {
            throw TestDetectorError.configurationInvalid
        }
    }

    // TODO: Refactor to avoid duplication
    private func getChangedTestTargets(
        from moduleHashes: [String: MD5Hash],
        currentModuleHashes: [String: MD5Hash],
        allModules: [IModule]
    ) throws -> [IModule] {
        let directoryURL = URL(fileURLWithPath: fileManager.currentDirectoryPath)
        let cacheURL = directoryURL.appendingPathComponent(cachePath)
        try fileManager.createDirectory(at: cacheURL, withIntermediateDirectories: true)
        let cacheFileURL = cacheURL.appendingPathComponent(filename)
        
        let allTestModules = allModules.filter { $0.isTest }
        let allTestModulesDict = allTestModules.dictionary
        
        let testModuleHashes = moduleHashes.filter {
            if let module = allTestModulesDict[$0.key], module.isTest {
                return true
            }
            return false
        }
        
        if fileManager.fileExists(atPath: cacheFileURL.path()) {
//            let currentHashesJsonString = try String(contentsOf: cacheFileURL)
//            guard let currentHashesJsonData = currentHashesJsonString.data(using: .utf8) else { return [] }
//            
//            let currentModuleHashes = try JSONSerialization.jsonObject(with: currentHashesJsonData, options: []) as? [String: MD5Hash] ?? [:]
            
            var testModules: [IModule] = []
            
            testModuleHashes.forEach { (key, value) in
                if let currentHash = currentModuleHashes[key], currentHash != value {
                    if let module = allTestModulesDict[key] {
                        testModules.append(module)
                    }
                }
            }
            
            try fileManager.removeItem(at: cacheFileURL)
            let jsonData = try JSONSerialization.data(withJSONObject: testModuleHashes, options: .prettyPrinted)
            try jsonData.write(to: cacheFileURL)
            
            return testModules
        } else {
//            let jsonData = try JSONSerialization.data(withJSONObject: testModuleHashes, options: .prettyPrinted)
//            try jsonData.write(to: cacheFileURL)
            return allTestModules
        }
    }

    private func fetchCache(with configuration: Configuration) throws -> [String: MD5Hash] {
        let currentBranchName = try GitUtil.getCurrentBranch()

        if configuration.cacheConfiguration.isLocal {
            let localURL = URL(fileURLWithPath: configuration.cacheConfiguration.local!)
                .appendingPathComponent("TestsCache")
                .appendingPathComponent(currentBranchName).appendingPathComponent(filename)

            let cacheFileURL = localURL.appendingPathComponent(filename)
            let currentHashesJsonString = try String(contentsOf: cacheFileURL)
            guard let currentHashesJsonData = currentHashesJsonString.data(using: .utf8) else { return [:] }

            let currentModuleHashes = try JSONSerialization.jsonObject(with: currentHashesJsonData, options: []) as? [String: MD5Hash] ?? [:]
            return currentModuleHashes
        }

        return [:]
    }

    private func storeCache(with configuration: Configuration, updatedModuleHashes: [String: MD5Hash]) throws {

        let currentBranchName = try GitUtil.getCurrentBranch()

        if configuration.cacheConfiguration.isLocal {
            let localURL = URL(fileURLWithPath: configuration.cacheConfiguration.local!).appendingPathComponent("TestsCache").appendingPathComponent(currentBranchName)
            try? fileManager.createDirectory(at: localURL, withIntermediateDirectories: true)
            let cacheFileURL = localURL.appendingPathComponent(filename)

            try? fileManager.removeItem(at: cacheFileURL)
            let jsonData = try JSONSerialization.data(withJSONObject: updatedModuleHashes, options: .prettyPrinted)
            try jsonData.write(to: cacheFileURL)
            return
        }

    }
}

