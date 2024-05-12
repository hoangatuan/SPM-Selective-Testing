//
//  Created by Tuan Hoang Anh on 11/5/24.
//

import Foundation

enum ModuleType {
    case local
    case remote(version: String)
}

protocol IModule {
    var name: String { get }
    var dependencies: [ModuleName] { get }
    var sourceCodes: [String] { get }
    var moduleType: ModuleType { get }
    var isTest: Bool { get }
}
