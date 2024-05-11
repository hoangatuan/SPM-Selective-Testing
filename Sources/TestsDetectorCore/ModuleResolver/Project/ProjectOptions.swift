
// https://github.com/FelixHerrmann/swift-package-list

import Foundation

public struct ProjectOptions {
    public var customDerivedDataPath: String?
    public var customSourcePackagesPath: String?
    
    public init(
        customDerivedDataPath: String? = nil,
        customSourcePackagesPath: String? = nil
    ) {
        self.customDerivedDataPath = customDerivedDataPath
        self.customSourcePackagesPath = customSourcePackagesPath
    }
}
