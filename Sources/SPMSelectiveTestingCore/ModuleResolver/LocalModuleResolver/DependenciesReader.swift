
import Foundation
import ShellOut

// https://developer.apple.com/documentation/packagedescription

final class DependenciesReader {
    private let packageRootDirectoryPath: String
    private let decoder: JSONDecoder
    private var retry = 0
    
    public init(
        packageRootDirectoryPath: String,
        decoder: JSONDecoder = .init()
    ) {
        self.packageRootDirectoryPath = packageRootDirectoryPath
        self.decoder = decoder
    }
    
    public func readDependencies() throws -> [LocalModule] {
        let jsonString = try dumpPackage()
        
        /// When using async-await, executing shell commands can sometimes return an empty string.
        /// Using GCD with Dispatch Group can solve this issue.
        /// However, modern concurrency has better performance than GCD. So I used modern concurrency here with retry mechanism to solve the issue.
        if jsonString.isEmpty && retry < 3 {
            debugPrint("retryyy")
            self.retry += 1
            return try readDependencies()
        }
        
        let jsonData = jsonString.data(using: .utf8)!
        return try decoder
            .decode(DumpPackageResponse.self, from: jsonData)
            .toModule()
    }
    
    private func dumpPackage() throws -> String {
        try shellOut(
            to: "/usr/bin/env",
            arguments: ["swift", "package", "dump-package"],
            at: packageRootDirectoryPath
        )
    }
}

private struct DumpPackageResponse: Decodable {
    let rootPaths: [String]
    let targets: [Target]
    
    struct Target: Decodable {
        let name: String
        let type: TargetType
        let dependencies: [Dependency]
        let path: String?
        let sources: [String]? // If this property is `nil`, Swift Package Manager includes all valid source files in the target's path
        let exclude: [String]
//        let settings
        
        struct Dependency: Decodable {
            let byName: [String?]?
            let product: [String?]?
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case packageKind
        case targets
    }
    
    enum PackageKindCodingKeys: String, CodingKey {
        case root
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rootPath = try container.nestedContainer(keyedBy: PackageKindCodingKeys.self, forKey: .packageKind)
        rootPaths = try rootPath.decode([String].self, forKey: .root)
        targets = try container.decode([Target].self, forKey: .targets)
    }
}

extension DumpPackageResponse {
    func toModule() -> [LocalModule] {
        targets.map { target in
            let byNameDependencies = target.dependencies.compactMap { $0.byName?.compactMap { $0 }.first }
            let productDependencies = target.dependencies.compactMap { $0.product?.compactMap { $0 }.first }
            let dependencies = byNameDependencies + productDependencies
            return LocalModule(
                name: target.name,
                type: target.type,
                dependencies: dependencies,
                root: rootPaths[0],
                path: target.path,
                sources: target.sources,
                exclude: target.exclude
            )
        }
    }
}
