//
//  File.swift
//  
//
//  Created by Tuan Hoang Anh on 4/5/24.
//

import Foundation
import Files

protocol SourceFileContentHashing {
    func hash(sources: [String]) throws -> MD5Hash
}

struct SourceFileContentHasher: SourceFileContentHashing {
    let contentHasher: ContentHashing
    init(contentHasher: ContentHashing = ContentHasher()) {
        self.contentHasher = contentHasher
    }
    
    func hash(sources: [String]) throws -> MD5Hash {
        var md5Hashes: [MD5Hash] = []
        
        try sources.forEach {
            if let folder = try? Folder(path: $0) {
                try folder.files.recursive.forEach { file in
                    let md5Hash = try hash(file: file)
                    md5Hashes.append(md5Hash)
                }
            } else {
                let file = try File(path: $0)
                let md5Hash = try hash(file: file)
                md5Hashes.append(md5Hash)
            }
        }
        
        let md5Hash = try contentHasher.hash(md5Hashes)
        return md5Hash
    }
    
    private func hash(file: File) throws -> MD5Hash {
        let contentData = try file.read()
        let md5Hash = try contentHasher.hash(contentData)
        return md5Hash
    }
}
