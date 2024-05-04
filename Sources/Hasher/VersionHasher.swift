//
//  File.swift
//  
//
//  Created by Tuan Hoang Anh on 4/5/24.
//

import Foundation

protocol VersionHashing {
    func hash(module: IModule) -> MD5Hash
}

struct VersionHasher: VersionHashing {
    func hash(module: IModule) -> MD5Hash {
        switch module.moduleType {
        case .local:
            return ""
        case let .remote(version):
            return version
        }
    }
}
