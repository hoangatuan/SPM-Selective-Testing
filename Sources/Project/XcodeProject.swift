
// https://github.com/FelixHerrmann/swift-package-list

import Foundation

struct ProjectPbxproj {
    let url: URL
}

extension ProjectPbxproj {
    var organizationName: String? {
        do {
            let contents = try String(contentsOf: url)
            let organizationNames = try regex("(?<=ORGANIZATIONNAME = \").*(?=\";)", on: contents)
            if organizationNames.isEmpty {
                let organizationNamesWithoutQuotes = try regex("(?<=ORGANIZATIONNAME = ).*(?=;)", on: contents)
                return organizationNamesWithoutQuotes.first
            } else {
                return organizationNames.first
            }
        } catch {
            return nil
        }
    }
}

struct XcodeProject: NativeProject {
    let fileURL: URL
    let options: ProjectOptions
    
    var name: String {
        return fileURL
            .deletingPathExtension()
            .lastPathComponent
    }
    
    var organizationName: String? {
        let url = fileURL.appendingPathComponent("project.pbxproj")
        let projectPbxproj = ProjectPbxproj(url: url)
        return projectPbxproj.organizationName
    }
    
    var workspaceURL: URL {
        return fileURL
    }
    
    var packageResolved: PackageResolved {
        get throws {
            let url = fileURL
                .appendingPathComponent("project.xcworkspace")
                .appendingPathComponent("xcshareddata")
                .appendingPathComponent("swiftpm")
                .appendingPathComponent("Package.resolved")
            return try PackageResolved(url: url)
        }
    }
}
