//
//  File.swift
//  
//
//  Created by Tuan Hoang Anh on 4/5/24.
//

import Foundation

struct RemoteModule: IModule {
    let name: String
    let moduleType: ModuleType
    
    init(name: String, version: String) {
        self.name = name
        self.moduleType = .remote(version: version)
    }
    
    var sourceCodes: [String] {
        []
    }
    
    var dependencies: [ModuleName] {
        []
    }
}
