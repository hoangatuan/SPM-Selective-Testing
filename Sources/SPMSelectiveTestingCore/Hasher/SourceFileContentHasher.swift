//
//  File.swift
//  
//
//  Created by Tuan Hoang Anh on 4/5/24.
//

import Foundation
import Files

protocol SourceFileContentHashing {
    func hash(sources: [String]) async throws -> MD5Hash
}

struct SourceFileContentHasher: SourceFileContentHashing {
    let contentHasher: ContentHashing
    init(contentHasher: ContentHashing = ContentHasher()) {
        self.contentHasher = contentHasher
    }

    func hash(sources: [String]) async throws -> MD5Hash {
        let files = try sources.map { try $0.asFiles() }.flatMap { $0 }

        let md5Hashes: [MD5Hash] = try await withThrowingTaskGroup(of: MD5Hash.self) { group in
            var md5Hashes: [MD5Hash] = []

            files.forEach { file in
                group.addTask {
                    return try await hash(file: file)
                }
            }

            for try await result in group {
                md5Hashes.append(result)
            }
            return md5Hashes
        }

        let sourceFilesHash = try contentHasher.hash(md5Hashes)
        return sourceFilesHash
    }

    private func hash(file: File) async throws -> MD5Hash {
        let contentData = try file.read()
        let md5Hash = try contentHasher.hash(contentData)
        return md5Hash
    }
}
