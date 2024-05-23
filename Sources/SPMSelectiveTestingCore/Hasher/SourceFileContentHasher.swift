//
//  File.swift
//  
//
//  Created by Tuan Hoang Anh on 4/5/24.
//

import Foundation
import Files
import ShellOut
import Zip

protocol SourceFileContentHashing {
    func hash(module: IModule) async throws -> MD5Hash
}

struct SourceFileContentHasher: SourceFileContentHashing {
    typealias FileName = String

    let contentHasher: ContentHashing
    init(contentHasher: ContentHashing = ContentHasher()) {
        self.contentHasher = contentHasher
    }

    func hash(module: IModule) async throws -> MD5Hash {
        /// Don't need to hash content of remote modulel
        guard let localModule = module as? LocalModule else { return "" }
        
        switch localModule.type {
        case .binary:
            return try hashBinary(module: localModule)
        default:
            return try await hashSourceFiles(module: localModule)
        }
    }

    private func hashBinary(module: LocalModule) throws -> MD5Hash {
        /// A binary module has checksum is a binary from remote. Therefore, we can rely on checksum directly
        if let checksum = module.checksum {
            return checksum
        }
        
        /// Otherwise, it's a local binary.
        /// https://github.com/apple/swift-package-manager/pull/3746
        
        guard let path = module.path else { throw SelectiveTestingError.calculateCheckSumFailed(moduleName: module.name)}
        
        if path.hasSuffix(".zip") {
            let checksum = try shellOut(to: "swift package compute-checksum \(path)")
            return checksum
        } 
        
        let filePath = module.root + "/\(path)"
        let zipFilePath = try Zip.quickZipFiles([URL(string: filePath)!], fileName: "\(module.name)-selective-testing")
        let checksum = try shellOut(to: "swift package compute-checksum \(zipFilePath.path())")
        try FileManager.default.removeItem(at: zipFilePath)
        return checksum
    }
    
    private func hashSourceFiles(module: LocalModule) async throws -> MD5Hash {
        let sources = module.sourceCodes
        let files = try sources.map { try $0.asFiles() }.flatMap { $0 }

        let md5HashesDic: [FileName: MD5Hash] = try await withThrowingTaskGroup(of: (fileName: String, hash: MD5Hash).self) { group in
            var md5Hashes: [FileName: MD5Hash] = [:]

            files.forEach { file in
                group.addTask {
                    return try await hash(file: file)
                }
            }

            for try await result in group {
                md5Hashes[result.fileName] = result.hash
            }
            return md5Hashes
        }

        /// Since we're running hash concurrently, we need to make sure the order is consistent in every run.
        let sourceFileHashes = files.map { md5HashesDic[$0.name] ?? "" }
        return try contentHasher.hash(sourceFileHashes)
    }
    
    private func hash(file: File) async throws -> (fileName: FileName, hash: MD5Hash) {
        let contentData = try file.read()
        let md5Hash = try contentHasher.hash(contentData)
        return (fileName: file.name, hash: md5Hash)
    }
}
