//
//  VersionedFile.swift
//  SwiftPackageListCore
//
//  Created by Felix Herrmann on 26.12.23.
//

// https://github.com/FelixHerrmann/swift-package-list

import Foundation

protocol VersionedFileStorage {
    init(url: URL) throws
}

protocol VersionedFile {
    associatedtype Storage = VersionedFileStorage
    
    var url: URL { get }
    var storage: Storage { get }
    
    init(url: URL) throws
}
