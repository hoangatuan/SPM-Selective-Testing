
import Foundation


public struct DependenciesReader {
    private let packageRootDirectoryPath: String
    private let decoder: JSONDecoder
    
    public init(
        packageRootDirectoryPath: String,
        decoder: JSONDecoder = .init()
    ) {
        self.packageRootDirectoryPath = packageRootDirectoryPath
        self.decoder = decoder
    }
    
    public func readDependencies() throws -> [Module] {
        let jsonString = try dumpPackage()
        let jsonData = jsonString.data(using: .utf8)!
        return try decoder
            .decode(DumpPackageResponse.self, from: jsonData)
            .toModule()
    }
    
    private func dumpPackage() throws -> String {
        try Command.run(
            launchPath: "/usr/bin/env",
            currentDirectoryPath: packageRootDirectoryPath,
            arguments: ["swift", "package", "dump-package"]
        )
    }
}

private struct DumpPackageResponse: Decodable {
//    let root
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
}

extension DumpPackageResponse {
    func toModule() -> [Module] {
        targets.map { target in
            let byNameDependencies = target.dependencies.compactMap { $0.byName?.compactMap { $0 }.first }
            let productDependencies = target.dependencies.compactMap { $0.product?.compactMap { $0 }.first }
            let dependencies = byNameDependencies + productDependencies
            return Module(
                name: target.name,
                type: target.type,
                dependencies: dependencies,
                path: target.path,
                sources: target.sources,
                exclude: target.exclude
            )
        }
    }
}
