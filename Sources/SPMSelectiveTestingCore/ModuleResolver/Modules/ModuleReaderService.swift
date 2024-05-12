//
//  File.swift
//  
//
//  Created by Tuan Hoang Anh on 11/5/24.
//

import Foundation
import Files

protocol ModulesResolverProtocol {
    static func resolveAllModules(at rootPath: String, projectPath: String) throws -> [IModule]
}

enum ModulesResolver: ModulesResolverProtocol {
    static func resolveAllModules(at rootPath: String, projectPath: String) throws -> [IModule] {
        let allModules: [IModule] = try findAllRemoteModules(at: projectPath) + findAllLocalModules(at: rootPath)
        return allModules
    }
    
    private static func findAllRemoteModules(at projectPath: String) throws -> [RemoteModule] {
        let projectFileURL = URL(fileURLWithPath: projectPath)
        let projectType = try ProjectType(fileURL: projectFileURL)
        let project = try projectType.project(fileURL: projectFileURL)
        let packages: [Package] = try project.packages()
        let remoteModules = packages.map { $0.modules }.compactMap { $0 }.flatMap { $0 }
        return remoteModules
    }
    
    private static func findAllLocalModules(at rootPath: String) throws -> [LocalModule] {
        let packageFiles = try findAllPackageFiles(at: rootPath)
        let localModules = try packageFiles.compactMap { file -> [LocalModule]? in
            guard let url = file.parent?.path else { return nil }
            let reader = DependenciesReader(packageRootDirectoryPath: url)
            let modules = try reader.readDependencies()
            return modules
        }.flatMap { $0 }
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
