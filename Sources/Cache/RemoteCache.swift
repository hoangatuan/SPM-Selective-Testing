//
//  File.swift
//  
//
//  Created by Tuan Hoang on 9/5/24.
//

import Foundation
import ShellOut

enum GitUtil {
    static func getCurrentBranch() throws -> String {
//        return try shellOut(to: "git", arguments: ["branch", "--show-current"])
        return "develop"
    }
}

final class RemoteCache {
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

    func fetchRemoteCache() throws -> [String: MD5Hash] {
        if !fileManager.fileExists(atPath: localPath + "/.git") {
            try clone()
        } else {
            try pull()
        }

        let cacheFileURL = URL(string: localPath + "/\(branch)" + "/TestsCache.json")!
        let currentHashesJsonString = try? String(contentsOf: cacheFileURL)
        guard let currentHashesJsonData = currentHashesJsonString?.data(using: .utf8) else { return [:] }

        let currentModuleHashes = try JSONSerialization.jsonObject(with: currentHashesJsonData, options: []) as? [String: MD5Hash] ?? [:]
        return currentModuleHashes
    }

    func update(hashes: [String: MD5Hash]) throws {
        let folderURL = URL(fileURLWithPath: localPath + "/\(branch)")
        try? fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)
        let cacheFileURL = folderURL.appendingPathComponent("TestsCache.json")
        try? fileManager.removeItem(at: cacheFileURL)
        let jsonData = try JSONSerialization.data(withJSONObject: hashes, options: .prettyPrinted)
        try jsonData.write(to: cacheFileURL)
        
        try push()
    }
    
    func clone() throws {
        try? fileManager.removeItem(at: URL(fileURLWithPath: localPath))
        let gitCommand = ShellOutCommand.gitClone(url: remote, to: localPath)
        try shellOut(to: gitCommand)
    }

    func pull() throws {
        let pullCommand = ShellOutCommand.gitPull()
        try shellOut(to: pullCommand, at: localPath)
    }

    func push() throws {
        let commitCommand = ShellOutCommand.gitCommit(message: "Update hashes of branch \(branch)")
        try shellOut(to: commitCommand, at: localPath)
        let pushCommand = ShellOutCommand.gitPush()
        try shellOut(to: pushCommand, at: localPath)
    }

}
