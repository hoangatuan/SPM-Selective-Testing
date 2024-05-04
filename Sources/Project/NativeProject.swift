
// https://github.com/FelixHerrmann/swift-package-list

import Foundation

protocol NativeProject: Project {
    var workspaceURL: URL { get }
    var packageResolved: PackageResolved { get throws }
}

extension NativeProject {
    func packages() throws -> [Package] {
        let packageResolved = try packageResolved
        
        let sourcePackages: SourcePackages
        if let sourcePackagesPath = options.customSourcePackagesPath {
            let sourcePackagesDirectory = URL(fileURLWithPath: sourcePackagesPath)
            sourcePackages = SourcePackages(url: sourcePackagesDirectory)
        } else {
            let derivedDataDirectory: URL
            if let derivedDataPath = options.customDerivedDataPath {
                derivedDataDirectory = URL(fileURLWithPath: derivedDataPath)
            } else {
                derivedDataDirectory = DerivedData.defaultDirectory
            }
            let derivedData = DerivedData(url: derivedDataDirectory)
            guard let buildDirectory = try derivedData.buildDirectory(project: self) else {
                throw RuntimeError("No build directory found in \(derivedData.url.path) for project \(fileURL.path)")
            }
            let sourcePackagesDirectory = buildDirectory.appendingPathComponent("SourcePackages")
            sourcePackages = SourcePackages(url: sourcePackagesDirectory)
        }
        
        return try packageResolved.packages(in: sourcePackages)
    }
}

