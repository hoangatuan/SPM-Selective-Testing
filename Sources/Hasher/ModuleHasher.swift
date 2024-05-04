//
//  File.swift
//  
//
//  Created by Tuan Hoang Anh on 4/5/24.
//

import Foundation

typealias ModuleName = String
typealias MD5Hash = String

enum ModuleHasherError: Error {
    case moduleNotFound
}

final class ModuleHasher {
    
    private let modules: [IModule]
    private var dic: [ModuleName: MD5Hash] = [:]
    private var modulesDic: [ModuleName: IModule] = [:]
    
    let contentHasher: ContentHashing
    let versionHasher: VersionHashing
    let sourceFileContentHasher: SourceFileContentHashing
    
    init(
        modules: [IModule],
        contentHasher: ContentHashing = ContentHasher(),
        sourceFileContentHasher: SourceFileContentHashing = SourceFileContentHasher(),
        versionHasher: VersionHashing = VersionHasher()
    ) {
        self.modules = modules
        self.modulesDic = modules.dictionary
        self.contentHasher = contentHasher
        self.sourceFileContentHasher = sourceFileContentHasher
        self.versionHasher = versionHasher
    }
    
    func generateHash() throws -> [ModuleName: MD5Hash] {
        try modules.forEach {
            try hash(module: $0)
        }
        
        return dic
    }
    
    @discardableResult
    private func hash(module: IModule) throws -> MD5Hash {
        /* To hash
         5. // swift version, deployment version?
         */
        
        if let hash = dic[module.name] { return hash }
        
        let sourcesHash = try sourceFileContentHasher.hash(sources: module.sourceCodes)
        let version = versionHasher.hash(module: module)
        let dependenciesHash = try module.dependencies.map {
            guard let module = modulesDic[$0] else {
                throw ModuleHasherError.moduleNotFound
            }
            return try hash(module: module)
        }
        
        var stringsToHash: [String] = [
            sourcesHash,
            module.name,
            version,
        ]
        
        stringsToHash += dependenciesHash
        
        let md5Hash: String = try contentHasher.hash(stringsToHash)
        dic[module.name] = md5Hash
        return md5Hash
    }
}

