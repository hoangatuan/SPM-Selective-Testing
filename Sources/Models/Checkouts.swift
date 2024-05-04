

// https://github.com/FelixHerrmann/swift-package-list

import Foundation

struct Checkouts: Directory {
    let url: URL
}

extension Checkouts {
    func modules(checkoutURL: URL) throws -> [Module]? {
        let checkoutName = checkoutURL.packageIdentity
        let checkoutPath = url.appendingPathComponent(checkoutName)
        
        let reader = DependenciesReader(packageRootDirectoryPath: checkoutPath.path())
        let modules = try reader.readDependencies()
        return modules
    }
}
