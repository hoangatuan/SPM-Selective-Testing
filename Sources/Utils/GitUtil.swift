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
        return try shellOut(to: "git", arguments: ["branch", "--show-current"])
    }
}
