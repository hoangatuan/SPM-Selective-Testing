//
//  File.swift
//  
//
//  Created by Tuan Hoang Anh on 1/5/24.
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

public struct Module {
    let name: String
    let type: TargetType
    let dependencies: [String]
    let root: String
    let path: String?
    let sources: [String]?
    let exclude: [String]
    
    var isTest: Bool {
        type == .test
    }
    
    var sourceCodes: [String] {
        var results: [String] = []
        var excludeDic: Set<String> = Set()
        results.forEach { excludeDic.insert($0) }
        
        if let sources = sources {
            sources.forEach {
                if let folder = try? Folder(path: $0) {
                    folder.files.recursive.forEach {
                        if !excludeDic.contains($0.path) {
                            results.append($0.path)
                        }
                    }
                } else if !excludeDic.contains($0) {
                    results.append($0)
                }
            }
            
            return results
        }
        
        if let path = path {
            let folder = try? Folder(path: path)
            folder?.files.recursive.forEach {
                if !excludeDic.contains($0.path) {
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
            if let folder = try? Folder(path: "\(root)/\(p)/\(name)") {
                folder.files.recursive.forEach {
                    if !excludeDic.contains($0.path) {
                        results.append($0.path)
                    }
                }
            }
        }
        
        return results
    }
}
