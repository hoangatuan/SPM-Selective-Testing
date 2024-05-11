//
//  Created by Tuan Hoang Anh
//

import Foundation

struct Checkouts: Directory {
    let url: URL
}

extension Checkouts {
    func modules(checkoutURL: URL) throws -> [LocalModule]? {
        let checkoutName = checkoutURL.packageIdentity
        let checkoutPath = url.appendingPathComponent(checkoutName)
        
        let reader = DependenciesReader(packageRootDirectoryPath: checkoutPath.path())
        let modules = try reader.readDependencies()
        return modules
    }
}
