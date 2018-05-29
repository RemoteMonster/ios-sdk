import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ios_sdkTests.allTests),
    ]
}
#endif