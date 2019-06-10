// NoSwizzlingTests.swift
//
// Copyright (C) 2016 Subito.it S.r.l (www.subito.it)
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SBTUITestTunnel
import Foundation
import XCTest

class MyApplication: SBTUITunneledApplication {
    override init() {
        super.init()
        launchArguments = [SBTUITunneledApplicationLaunchOptionResetFilesystem]
    }
}

class NoSwizzlingTests: XCTestCase {

    let app = MyApplication()

    override func setUp() {
        super.setUp()

        app.launchTunnel()

        expectation(for: NSPredicate(format: "count > 0"), evaluatedWith: app.tables)
        waitForExpectations(timeout: 15.0, handler: nil)

        Thread.sleep(forTimeInterval: 1.0)
    }

    func testSingleDownload() {
        let randomString = ProcessInfo.processInfo.globallyUniqueString

        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let testFilePath = paths.first!.appending("/test_file_a.txt")

        if FileManager.default.fileExists(atPath: testFilePath) {
            try! FileManager.default.removeItem(atPath: testFilePath)
        }

        try! (randomString.data(using: .utf8))?.write(to: URL(fileURLWithPath: testFilePath))

        app.uploadItem(atPath: testFilePath, toPath: "test_file_b.txt", relativeTo: .documentDirectory)

        let uploadData = app.downloadItems(fromPath: "test_file_b.txt", relativeTo: .documentDirectory)?.first!

        let uploadedString = String(data: uploadData!, encoding: .utf8)

        XCTAssertTrue(randomString == uploadedString)
    }
}
