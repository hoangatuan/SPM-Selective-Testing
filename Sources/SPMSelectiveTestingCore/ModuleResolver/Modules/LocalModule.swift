//
//  Created by Tuan Hoang Anh on 11/5/24.
//

import Foundation
import Files

enum TargetType : String, Codable {
    case regular
    case executable
    case test
    case system
    case binary
    case plugin
    case macro
}

struct Platform: Decodable {
    let platformName: String
    let version: String
    
    var id: String {
        return "\(platformName)-\(version)"
    }
}

public struct LocalModule: IModule {
    let name: String
    let type: TargetType
    let dependencies: [String]
    let root: String
    
    /// The path of the target, relative to the package root.
    /// If the path is `nil`, Swift Package Manager looks for a target's source files at
    /// predefined search paths and in a subdirectory with the target's name.
    /// - `Sources`, `Source`, `src`, and `srcs` for regular targets
    /// - `Tests`, `Sources`, `Source`, `src`, and `srcs` for test targets
    /// For example, Swift Package Manager looks for source files inside the
    /// `[PackageRoot]/Sources/[TargetName]` directory.
    let path: String?
    
    /// The source files in this target.
    /// If this property is `nil`, Swift Package Manager includes all valid source files in the
    /// target's path and treats specified paths as relative to the target's
    /// path.
    let sources: [String]?
    
    /// The paths to source and resource files that you don't want to include in the target.
    /// Excluded paths are relative to the target path.
    let exclude: [String]
    let platforms: [Platform]
    
    var isTest: Bool {
        type == .test
    }
    
    var moduleType: ModuleType {
        return .local
    }
    
    var sourceCodes: [String] {
        var results: [String] = []

        
        if let sources = sources {
            let files = sources.map { try! $0.asFiles() }.flatMap { $0 }
            files.forEach {
                results.append($0.path)
            }
            
            return results       
        }
        
        if let path = path {
            let folder = try? Folder(path: path)
            var exculdeFiles: Set<String> = Set()
            exclude.forEach { file in
                let excludeFilePath = path + "/\(file)"
                exculdeFiles.insert(excludeFilePath)
            }
            
            folder?.files.recursive.forEach {
                if !exculdeFiles.contains($0.path) {
                    results.append($0.path)
                }
            }
            return results
        }
        
        var possibility: [String] = ["Sources", "Source", "src", "srcs"]
        if isTest {
            possibility.append("Tests")
        }
        
        for p in possibility {
            let rootPath = "\(root)/\(p)/\(name)"
            
            if let folder = try? Folder(path: rootPath) {
                var exculdeFiles: Set<String> = Set()
                exclude.forEach { file in
                    let excludeFilePath = rootPath + "/\(file)"
                    exculdeFiles.insert(excludeFilePath)
                }
                
                folder.files.recursive.forEach {
                    if !exculdeFiles.contains($0.path) {
                        results.append($0.path)
                    }
                }
            }
        }
        
        return results
    }
}
