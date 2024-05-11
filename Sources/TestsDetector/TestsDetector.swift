
import ArgumentParser
import Foundation
import TestsDetectorCore

struct TestSelectiveCommand: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "testselective",
        abstract: "🧪 Detect only test that needs to be executed.",
        version: "0.0.1",
        subcommands: [
            Init.self,
            Run.self,
        ],
        defaultSubcommand: Run.self
    )
}

public enum TestsDetector {
    public static func start() async {
        await TestSelectiveCommand.main()
    }
}


