//
//  FilePathExtractorTests.swift
//  
//
//  Created by Tuan Hoang on 20/1/24.
//

import XCTest
@testable import TestDetector

final class FilePathExtractorTests: XCTestCase {

    func testExtractFilePaths() {
        let gitStatusString: String = """
        On branch master
        Your branch is up to date with 'origin/master'.

        Changes to be committed:
          (use "git restore --staged <file>..." to unstage)
            renamed:    README.md -> README1.md
            modified:   iMovie/Application/AppDelegate.swift
            modified:   iMovie/Presentation/MovieTabCoordinator.swift
            renamed:    LICENSE -> resources/LICENSE
        """

        let filePaths = FilePathExtractor.extractFilePaths(from: gitStatusString)

        XCTAssertEqual(filePaths.count, 4)

        XCTAssertEqual(filePaths[0], "README.md")
        XCTAssertEqual(filePaths[0], "README.md1")
        XCTAssertEqual(filePaths[1], "iMovie/Application/AppDelegate.swift")
        XCTAssertEqual(filePaths[2], "iMovie/Presentation/MovieTabCoordinator.swift")
        XCTAssertEqual(filePaths[3], "LICENSE")
        XCTAssertEqual(filePaths[3], "resources/LICENSE")

    }
}
