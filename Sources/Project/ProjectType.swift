
// https://github.com/FelixHerrmann/swift-package-list
import Foundation

public enum ProjectType {
    case xcodeProject
    case xcodeWorkspace
//    case swiftPackage
}

extension ProjectType {
    public init(fileURL: URL) throws {
        switch (fileURL.deletingPathExtension().lastPathComponent, fileURL.pathExtension) {
        case (_, "xcodeproj"):
            self = .xcodeProject
        case (_, "xcworkspace"):
            self = .xcodeWorkspace
//        case ("Package", "swift"):
//            self = .swiftPackage
        default:
            throw RuntimeError("\(fileURL.lastPathComponent) is not supported")
        }
    }
}

extension ProjectType {
     func project(fileURL: URL, options: ProjectOptions = ProjectOptions()) throws -> any Project {
        switch self {
        case .xcodeProject:
            return XcodeProject(fileURL: fileURL, options: options)
        case .xcodeWorkspace:
            return XcodeWorkspace(fileURL: fileURL, options: options)
//        case .swiftPackage:
//            return SwiftPackage(fileURL: fileURL, options: options)
        }
    }
}
