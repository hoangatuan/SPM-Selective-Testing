import Foundation

Task {
    await SelectiveTesting.start()
    exit(0)
}

RunLoop.current.run()
