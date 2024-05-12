//
//  File.swift
//  
//
//  Created by Tuan Hoang Anh on 11/5/24.
//

import Foundation

final class LocalCacheService: CacheServiceProtocol {
    
    private let branch: String
    private let localPath: String
    private let fileManager: FileManager
    
    init(
        branch: String,
        localPath: String,
        fileManager: FileManager = FileManager()
    ) {
        self.branch = branch
        self.localPath = localPath
        self.fileManager = fileManager
    }
    
    private var folderURL: URL {
        URL(fileURLWithPath: localPath)
            .appendingPathComponent(branch)
    }
    
    var cacheFileURL: URL {
        folderURL.appendingPathComponent(Constants.cacheFileName)
    }
    
    func fetch() throws -> Cache {
        guard let cacheData = try? Data(contentsOf: cacheFileURL),
              let cache = try JSONSerialization.jsonObject(with: cacheData, options: []) as? Cache else {
            return [:]
        }
        return cache
    }
    
    func update(with cache: Cache) throws {
        try? fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)
        try? fileManager.removeItem(at: cacheFileURL)
        let jsonData = try JSONSerialization.data(withJSONObject: cache, options: .prettyPrinted)
        try jsonData.write(to: cacheFileURL)
    }
}
