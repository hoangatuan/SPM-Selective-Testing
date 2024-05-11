import Foundation

Task {
    await TestsDetector.start()
    exit(0)
}

RunLoop.current.run()
