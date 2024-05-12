//
//  File.swift
//  
//
//  Created by Tuan Hoang Anh on 11/5/24.
//

import Foundation
import ShellOut

protocol GitUtilProtocol {
    static func getCurrentBranch(at folderURL: String) throws -> String
}

enum GitUtil: GitUtilProtocol {
    static func getCurrentBranch(at folderURL: String) throws -> String {
        return try shellOut(to: "git", arguments: ["branch", "--show-current"], at: folderURL)
    }
}
