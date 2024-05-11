
// https://github.com/FelixHerrmann/swift-package-list

import Foundation

struct Package {
    
    /// The package identity based on it's source location.
    public let identity: String
    
    /// The name of the package.
    public let name: String
    
    /// The version of the package.
    ///
    /// Could be `nil` if the package's dependency-rule is branch or commit.
    public let version: String?
    
    /// The name of the branch.
    ///
    /// Could be `nil` if the package's dependency-rule is version or commit.
    public let branch: String?
    
    /// The exact revision/commit.
    ///
    /// This is always present, regardless if the package's dependency-rule is version or branch.
    public let revision: String
    
    /// The URL to the git-repository.
    public let repositoryURL: URL
    
    public let modules: [RemoteModule]?
    
    public init(
        identity: String,
        name: String,
        version: String?,
        branch: String?,
        revision: String,
        repositoryURL: URL,
        modules: [RemoteModule]?
    ) {
        self.identity = identity
        self.name = name
        self.version = version
        self.branch = branch
        self.revision = revision
        self.repositoryURL = repositoryURL
        self.modules = modules
    }
}
