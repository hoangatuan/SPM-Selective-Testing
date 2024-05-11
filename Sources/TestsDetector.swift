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

        let branchName = try GitUtil.getCurrentBranch()
        debugPrint("Tuanha24: \(branchName)")

        // 1. Load configuration
        guard let configuration = try loadConfiguration() else {
            throw TestDetectorError.configurationNotFound
        }
        
        let remoteCache = RemoteCache(
            remote: URL(string: configuration.cacheConfiguration.remote!)!,
            localPath: configuration.cacheConfiguration.local,
            branch: try GitUtil.getCurrentBranch()
        )

        var testplan = try TestPlanGenerator.readTestPlan(filePath: testPlanPath)
        
        var allModules: [IModule] = []
        
        // 2. Find all local modules
        let packageFiles = try! findPackageFiles()
        let modules = try packageFiles.compactMap { file -> [Module]? in
            guard let url = file.parent?.path else { return nil }
            let reader = DependenciesReader(packageRootDirectoryPath: url)
            let modules = try reader.readDependencies()
            return modules
        }.flatMap { $0 }
        
        // 3. Find all remote modules
        let projectFileURL = URL(fileURLWithPath: projectPath)
        let projectType = try ProjectType(fileURL: projectFileURL)
        let project = try projectType.project(fileURL: projectFileURL)
        let packages: [Package] = try project.packages()
        let remoteModules = packages.map { $0.modules }.compactMap { $0 }.flatMap { $0 }
        
        allModules += modules
        allModules += remoteModules
        
        // 4. Get current hashes
        /// Remote
        let currentModuleHashes = try remoteCache.fetchRemoteCache()
        /// local
//        let currentModuleHashes = try fetchCache(with: configuration)
        
        // Generate module hashes
        let moduleHasher = ModuleHasher(modules: allModules)
        let allModuleHashes = try moduleHasher.generateHash()
        let enabledTestModules = testplan.testTargets.filter { $0.enabled ?? true }.map(\.target.name)
        let enabledTestModuleHashes = allModuleHashes.filter { enabledTestModules.contains($0.key) }
        
        // Find changed test targets
        let testTargets = try getChangedTestTargets(from: enabledTestModuleHashes, currentModuleHashes: currentModuleHashes, allModules: allModules).map { $0.name }

        debugPrint(testTargets)
        
        if testTargets.isEmpty {
            print("No test targets need to be run")
            return
        }
        
        // Update test plan
        TestPlanGenerator.updateTestPlanTargets(testPlan: &testplan, affectedTargets: Set(testTargets))
        try TestPlanGenerator.writeTestPlan(testplan, filePath: testPlanPath)

        // Run test
        try shellOut(to: "xcodebuild", arguments: configuration.testCommandArguments)
        
        // Store cache
        /// Local
//        try storeCache(with: configuration, updatedModuleHashes: enabledTestModuleHashes)
        /// Remote
        try remoteCache.update(hashes: enabledTestModuleHashes)

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

    private func getChangedTestTargets(
        from testModuleHashes: [String: MD5Hash],
        currentModuleHashes: [String: MD5Hash],
        allModules: [IModule]
    ) throws -> [IModule] {
        
        let allTestModules = allModules.filter { $0.isTest }
        let allTestModulesDict = allTestModules.dictionary
        
        var testModules: [IModule] = []
        testModuleHashes.forEach { (key, value) in
            guard let module = allTestModulesDict[key] else { return }
            
            if let currentHash = currentModuleHashes[key] {
                if currentHash != value {
                    testModules.append(module)
                }
            } else {
                testModules.append(module)
            }
        }
        
        return testModules
    }

    private func fetchCache(with configuration: Configuration) throws -> [String: MD5Hash] {
        let currentBranchName = try GitUtil.getCurrentBranch()

        if configuration.cacheConfiguration.isLocal {
            let localURL = URL(fileURLWithPath: configuration.cacheConfiguration.local)
//                .appendingPathComponent(".testsCache")
                .appendingPathComponent(currentBranchName)

            let cacheFileURL = localURL.appendingPathComponent(filename)
            let currentHashesJsonString = try? String(contentsOf: cacheFileURL)
            guard let currentHashesJsonData = currentHashesJsonString?.data(using: .utf8) else { return [:] }

            let currentModuleHashes = try JSONSerialization.jsonObject(with: currentHashesJsonData, options: []) as? [String: MD5Hash] ?? [:]
            return currentModuleHashes
        }

        return [:]
    }

    private func storeCache(with configuration: Configuration, updatedModuleHashes: [String: MD5Hash]) throws {
        let currentBranchName = try GitUtil.getCurrentBranch()

        if configuration.cacheConfiguration.isLocal {
            let localURL = URL(fileURLWithPath: configuration.cacheConfiguration.local)
//                .appendingPathComponent(".testsCache")
                .appendingPathComponent(currentBranchName)
            try? fileManager.createDirectory(at: localURL, withIntermediateDirectories: true)
            let cacheFileURL = localURL.appendingPathComponent(filename)

            try? fileManager.removeItem(at: cacheFileURL)
            let jsonData = try JSONSerialization.data(withJSONObject: updatedModuleHashes, options: .prettyPrinted)
            try jsonData.write(to: cacheFileURL)
            return
        }

    }
}

