//
//  File.swift
//  
//
//  Created by Tuan Hoang Anh on 7/5/24.
//

import ArgumentParser
import Foundation

//struct Init: ParsableCommand {
//    
//    static let configuration = CommandConfiguration(
//        commandName: "init",
//        abstract: "Creates the configuration file"
//    )
//    
//    private let directory: String
//    private let fileManager: FileManager
//    
//    public init(
//        directory: String = FileManager.default.currentDirectoryPath,
//        fileManager: FileManager = FileManager.default
//    ) {
//        self.directory = directory
//        self.fileManager = fileManager
//    }
//    
//    public init(from decoder: Decoder) throws {
//        self.init(
//            directory: FileManager.default.currentDirectoryPath,
//            fileManager: .default
//        )
//    }
//    
//    public init() {
//        self.init(
//            directory: FileManager.default.currentDirectoryPath,
//            fileManager: .default
//        )
//    }
//    
//    func run() throws {
//        let directoryContents = fileManager.subpaths(atPath: directory) ?? []
//        fileManager.createFile(
//            atPath: "\(directory)/\(Constants.fileNameWithExtension)",
//            contents: Data(),
//            attributes: nil
//        )
//    }
//}
