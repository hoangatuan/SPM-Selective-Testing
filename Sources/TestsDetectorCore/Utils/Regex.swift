//
//  File.swift
//  
//
//  Created by Tuan Hoang Anh on 4/5/24.
//

import Foundation

func regex(_ pattern: String, on fileContent: String) throws -> [String] {
    let regex = try NSRegularExpression(pattern: pattern)
    let matches = regex.matches(in: fileContent, range: NSRange(location: 0, length: fileContent.count))
    return matches.compactMap { result in
        guard let range = Range(result.range, in: fileContent) else { return nil }
        return String(fileContent[range])
    }
}
