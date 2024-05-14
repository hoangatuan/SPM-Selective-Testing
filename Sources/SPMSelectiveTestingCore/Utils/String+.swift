//
//  File.swift
//  
//
//  Created by Tuan Hoang on 14/5/24.
//

import Foundation
import Files

extension String {
    func asFiles() throws -> [File] {
        if let folder = try? Folder(path: self) {
            return folder.files.recursive.map { $0 }
        } else {
            let file = try File(path: self)
            return [file]
        }
    }
}

