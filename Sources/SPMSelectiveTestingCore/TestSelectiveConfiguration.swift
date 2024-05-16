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

public struct SelectiveTestingConfiguration: Codable {
    let testCommandArguments: [String]
    let cacheConfiguration: CacheConfiguration

    enum CodingKeys: String, CodingKey {
        case testCommandArguments = "arguments"
        case cacheConfiguration = "cache_repo"
    }
}

public extension SelectiveTestingConfiguration {
    func asYamlData() -> Data {
        let encoder = YAMLEncoder()
        return (try! encoder.encode(self)).data(using: .utf8)!
    }
}

public extension SelectiveTestingConfiguration {
    private static let defaultCacheConfiguration = CacheConfiguration(local: "./test-selective-cache", remote: nil)
    
    static func generateDefaultCongiruration() -> SelectiveTestingConfiguration {
        let directory = FileManager.default.currentDirectoryPath
        let directoryContents = (FileManager.default.subpaths(atPath: directory) ?? []).map(URL.init(fileURLWithPath:))
        
        let generators = [
            generateXcodeProjectConfiguration,
            generateXcodeWorkspaceConfiguration
        ]
        
        return generators
            .compactMap { $0(directoryContents) }
            .first ?? .init(
                testCommandArguments: arguments(projectName: "YOUR_PROJECT_NAME", isWorkSpace: false),
                cacheConfiguration: defaultCacheConfiguration
            )
    }
    
    private static func generateXcodeProjectConfiguration(from directoryContents: [URL]) -> SelectiveTestingConfiguration? {
        guard !directoryContainsXcodeWorkspace(directoryContents),
              let index = directoryContents.firstIndex(where: { $0.lastPathComponent.contains(".xcodeproj") }),
              let arguments = arguments(forProjectFileAt: directoryContents[index], isWorkSpace: false)
        else {
            return nil
        }

        return SelectiveTestingConfiguration(
            testCommandArguments: arguments,
            cacheConfiguration: defaultCacheConfiguration
        )
    }

    private static func generateXcodeWorkspaceConfiguration(from directoryContents: [URL]) -> SelectiveTestingConfiguration? {
        guard directoryContainsXcodeWorkspace(directoryContents),
              let index = directoryContents.firstIndex(where: { $0.lastPathComponent.contains(".xcodeproj") }),
              let arguments = arguments(forProjectFileAt: directoryContents[index], isWorkSpace: true)
        else {
            return nil
        }

        return SelectiveTestingConfiguration(
            testCommandArguments: arguments,
            cacheConfiguration: defaultCacheConfiguration
        )
    }

    private static func directoryContainsXcodeWorkspace(_ directoryContents: [URL]) -> Bool {
        let indexOfUserGeneratedWorkSpace = directoryContents
            .exclude { $0.absoluteString.contains("project.xcworkspace") }
            .firstIndex { $0.lastPathComponent.contains(".xcworkspace") }

        return indexOfUserGeneratedWorkSpace != nil
    }

    private static func arguments(
        forProjectFileAt url: URL,
        isWorkSpace: Bool
    ) -> [String]? {
        guard let projectName = url.lastPathComponent.split(separator: ".").first else {
            return nil
        }

        return arguments(projectName: String(projectName), isWorkSpace: isWorkSpace)
    }
    
    private static func arguments(
        projectName:String,
        isWorkSpace: Bool
    ) -> [String] {
        let defaultArguments = [
            isWorkSpace ? "-workspace" : "-project",
            isWorkSpace ? "\(projectName).xcworkspace" : "\(projectName).xcodeproj",
            "-scheme",
            "\(projectName)",
        ]

        let destination = ["-destination 'platform=iOS Simulator,name=iPhone 15 Plus'"]

        return defaultArguments + destination + ["clean"] + ["test"]
    }
}
