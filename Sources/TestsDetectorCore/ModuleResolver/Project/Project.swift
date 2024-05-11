
// https://github.com/FelixHerrmann/swift-package-list

import Foundation

protocol Project {
    var fileURL: URL { get }
    var options: ProjectOptions { get }
    var name: String { get }
    var organizationName: String? { get }
    
    func packages() throws -> [Package]
}

extension Project {
    var organizationName: String? {
        return nil
    }
}
