//
//  File.swift
//  
//
//  Created by Tuan Hoang Anh on 2/5/24.
//

import Foundation

extension Array where Element == IModule {
    var dictionary: [ModuleName: IModule] {
        var dic: [ModuleName: IModule] = [:]
        forEach {
            dic[$0.name] = $0
        }
        return dic
    }
}
