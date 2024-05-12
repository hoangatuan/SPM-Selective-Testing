//
//  File.swift
//  
//
//  Created by Tuan Hoang on 9/5/24.
//

import Foundation
import ShellOut

final class RemoteCacheService: CacheServiceProtocol {
    private let remote: URL
    private let localPath: String
    private let branch: String
    private let fileManager: FileManager

    init(
        remote: URL,
        localPath: String,
        branch: String,
        fileManager: FileManager = FileManager()
    ) {
        self.remote = remote
        self.localPath = localPath
        self.branch = branch
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
        if !fileManager.fileExists(atPath: localPath + "/.git") {
            try clone()
        } else {
            try pull()
        }

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
        try push()
    }
    
    private func clone() throws {
        try? fileManager.removeItem(at: URL(fileURLWithPath: localPath))
        let gitCommand = ShellOutCommand.gitClone(url: remote, to: localPath)
        try shellOut(to: gitCommand)
    }

    private func pull() throws {
        let pullCommand = ShellOutCommand.gitPull()
        try shellOut(to: pullCommand, at: localPath)
    }

    private func push() throws {
        let commitCommand = ShellOutCommand.gitCommit(message: "Update hashes of branch \(branch)")
        try shellOut(to: commitCommand, at: localPath)
        let pushCommand = ShellOutCommand.gitPush()
        try shellOut(to: pushCommand, at: localPath)
    }

}
