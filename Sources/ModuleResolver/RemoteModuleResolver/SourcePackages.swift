//
//  SourcePackages.swift
//  SwiftPackgageListCore
//
//  Created by Felix Herrmann on 26.12.23.
//

// https://github.com/FelixHerrmann/swift-package-list

import Foundation

protocol Directory {
    var url: URL { get }
    
    init(url: URL)
}

struct SourcePackages: Directory {
    let url: URL
}

extension SourcePackages {
    var checkouts: Checkouts {
        let checkoutsURL = url.appendingPathComponent("checkouts")
        return Checkouts(url: checkoutsURL)
    }
    
    var workspaceState: WorkspaceState {
        get throws {
            let fileURL = url.appendingPathComponent("workspace-state.json")
            return try WorkspaceState(url: fileURL)
        }
    }
}
