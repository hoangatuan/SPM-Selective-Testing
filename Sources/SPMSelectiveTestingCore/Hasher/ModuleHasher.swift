//
//  Created by Tuan Hoang Anh on 4/5/24.
//

import Foundation

enum ModuleHasherError: Error {
    case moduleNotFound
}

protocol ModuleHashing {
    func generateHash() async throws -> [ModuleName: MD5Hash]
}

actor ModuleHasher: ModuleHashing {

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
    
    func generateHash() async throws -> [ModuleName: MD5Hash] {
        for module in modules {
            try await self.hash(module: module)
        }

        return dic
    }
    
    /* To hash
     - swift version, deployment version?
     */
    @discardableResult
    private func hash(module: IModule) async throws -> MD5Hash {
        if let hash = dic[module.name] { return hash }
        
        let sourcesHash = try await sourceFileContentHasher.hash(sources: module.sourceCodes)
        let version = versionHasher.hash(module: module)
        let dependenciesHash = try await hashDependencies(of: module)

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

    private func hashDependencies(of module: IModule) async throws -> [MD5Hash] {
        var hashes: [MD5Hash] = []
        for moduleName in module.dependencies {
            guard let module = modulesDic[moduleName] else {
                throw ModuleHasherError.moduleNotFound
            }

            hashes.append(try await hash(module: module))
        }

        return hashes
    }
}

