//
//  File.swift
//  
//
//  Created by Tuan Hoang Anh on 11/5/24.
//

import Foundation

protocol CacheServiceProtocol {
    func fetch() throws -> Cache
    func update(with cache: Cache) throws
}
