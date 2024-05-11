//
//  Created by Tuan Hoang Anh on 7/5/24.
//

import Foundation
import Yams

public struct CacheConfiguration: Codable {
    let local: String
    let remote: String?

    var isLocal: Bool {
        return remote == nil
    }
}

public struct TestSelectiveConfiguration: Codable {
    let testCommandArguments: [String]
    let cacheConfiguration: CacheConfiguration

    enum CodingKeys: String, CodingKey {
        case testCommandArguments = "arguments"
        case cacheConfiguration = "cache_repo"
    }
}

public extension TestSelectiveConfiguration {
    func asYamlData() -> Data {
        let encoder = YAMLEncoder()
        return (try! encoder.encode(self)).data(using: .utf8)!
    }
}

public extension TestSelectiveConfiguration {
    static func generateDefaultCongiruration() -> TestSelectiveConfiguration {
        let directory = FileManager.default.currentDirectoryPath
        let directoryContents = (FileManager.default.subpaths(atPath: directory) ?? []).map(URL.init(fileURLWithPath:))
        
        let generators = [
            generateXcodeProjectConfiguration,
            generateXcodeWorkspaceConfiguration
        ]
        
        return generators
            .compactMap { $0(directoryContents) }
            .first!
    }
    
    static func generateXcodeProjectConfiguration(from directoryContents: [URL]) -> TestSelectiveConfiguration? {
        guard !directoryContainsXcodeWorkspace(directoryContents),
              let index = directoryContents.firstIndex(where: { $0.lastPathComponent.contains(".xcodeproj") }),
              let arguments = arguments(forProjectFileAt: directoryContents[index], isWorkSpace: false)
        else {
            return nil
        }

        return TestSelectiveConfiguration(
            testCommandArguments: arguments,
            cacheConfiguration: .init(
                local: "./test-selective-cache",
                remote: nil
            )
        )
    }

    static func generateXcodeWorkspaceConfiguration(from directoryContents: [URL]) -> TestSelectiveConfiguration? {
        guard directoryContainsXcodeWorkspace(directoryContents),
              let index = directoryContents.firstIndex(where: { $0.lastPathComponent.contains(".xcodeproj") }),
              let arguments = arguments(forProjectFileAt: directoryContents[index], isWorkSpace: true)
        else {
            return nil
        }

        return TestSelectiveConfiguration(
            testCommandArguments: arguments,
            cacheConfiguration: .init(
                local: "./test-selective-cache",
                remote: nil
            )
        )
    }

    static func directoryContainsXcodeWorkspace(_ directoryContents: [URL]) -> Bool {
        let indexOfUserGeneratedWorkSpace = directoryContents
            .exclude { $0.absoluteString.contains("project.xcworkspace") }
            .firstIndex { $0.lastPathComponent.contains(".xcworkspace") }

        return indexOfUserGeneratedWorkSpace != nil
    }

    static func arguments(
        forProjectFileAt url: URL,
        isWorkSpace: Bool
    ) -> [String]? {
        guard let projectName = url.lastPathComponent.split(separator: ".").first else {
            return nil
        }

        let defaultArguments = [
            isWorkSpace ? "-workspace" : "-project",
            isWorkSpace ? "\(projectName).xcworkspace" : "\(projectName).xcodeproj",
            "-scheme",
            "\(projectName)",
        ]

        let destination = ["-destination", "platform=iOS Simulator,name=iPhone 15 Plus"]

        return defaultArguments + destination + ["clean"] + ["test"]
    }
}
