//
//  File.swift
//  
//
//  Created by Tuan Hoang Anh on 11/5/24.
//

import Foundation
import Files

protocol ModulesResolverProtocol {
    static func resolveAllModules(at rootPath: String, projectPath: String) async throws -> [IModule]
}

enum ModulesResolver: ModulesResolverProtocol {
    static func resolveAllModules(at rootPath: String, projectPath: String) async throws -> [IModule] {
        async let remoteModules = findAllRemoteModules(at: projectPath)
        async let localModules = findAllLocalModules(at: rootPath)
        let allModules: [IModule] = try await (remoteModules + localModules)
        return allModules
    }
    
    private static func findAllRemoteModules(at projectPath: String) async throws -> [RemoteModule] {
        let projectFileURL = URL(fileURLWithPath: projectPath)
        let projectType = try ProjectType(fileURL: projectFileURL)
        let project = try projectType.project(fileURL: projectFileURL)
        let packages: [Package] = try project.packages()
        let remoteModules = packages.map { $0.modules }.compactMap { $0 }.flatMap { $0 }
        return remoteModules
    }
    
    private static func findAllLocalModules(at rootPath: String) async throws -> [LocalModule] {
        let packageFiles = try findAllPackageFiles(at: rootPath)
        let localModules = try await withThrowingTaskGroup(of: [LocalModule].self) { group in
            var modules: [LocalModule] = []
            for file in packageFiles {
                group.addTask {
                    guard let url = file.parent?.path else { return [] }
                    let reader = DependenciesReader(packageRootDirectoryPath: url)
                    let modules = try reader.readDependencies()
                    return modules
                }
            }

            for try await module in group {
                modules.append(contentsOf: module)
            }

            return modules
        }
        return localModules
    }
    
    private static func findAllPackageFiles(at rootPath: String) throws -> [File] {
        var files: [File] = []
        for file in try Folder(path: rootPath).files.recursive {
            if file.name == "Package.swift" {
                files.append(file)
            }
        }
        return files
    }
}
