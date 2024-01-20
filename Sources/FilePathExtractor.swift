//
//  File.swift
//  
//
//  Created by Tuan Hoang on 20/1/24.
//

import Foundation
import ShellOut

struct FilePathExtractor {

    fileprivate init() { }

    static func extractFilePaths() throws -> [String] {
        let result = try shellOut(to: "git status")
        return extractFilePaths(from: result)
    }

    static func extractFilePaths(from gitStatus: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: #"^\s+(?:modified|new file|deleted|renamed):\s+(.+)$"#, options: .anchorsMatchLines)
            let matches = regex.matches(in: gitStatus, options: [], range: NSRange(location: 0, length: gitStatus.utf16.count))

            var filePaths: [String] = []

            matches.forEach { match in
                let range = match.range(at: 1)
                if let swiftRange = Range(range, in: gitStatus) {
                    let filePath = String(gitStatus[swiftRange])
                    let paths = filePath.components(separatedBy: "->")
                    paths.forEach {
                        filePaths.append($0.trimmingCharacters(in: .whitespacesAndNewlines))
                    }
                }
            }

            return filePaths
        } catch {
            print("Error creating regex: \(error)")
            return []
        }
    }

}
