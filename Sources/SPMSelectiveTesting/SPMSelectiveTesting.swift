
import ArgumentParser
import Foundation
import SPMSelectiveTestingCore

struct SPMSelectiveTestingCommand: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "spm-selective-testing",
        abstract: "🧪 Detect only test that needs to be executed.",
        version: "0.0.1",
        subcommands: [
            Init.self,
            Run.self,
        ],
        defaultSubcommand: Run.self
    )
}

public enum SelectiveTesting {
    public static func start() async {
        await SPMSelectiveTestingCommand.main()
    }
}


