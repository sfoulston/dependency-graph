@testable import XcodeWorkspace
@testable import XcodeWorkspaceParserLive
@testable import PackageSwiftFileParser
@testable import PackageSwiftFile
import XCTest

final class XcodeWorkspaceParserLiveTests: XCTestCase {
    func testParsesWorkspaceName() throws {
        let parser = XcodeWorkspaceParserLive(fileSystem: FileSystemMock(), packageSwiftFileParser: PackageSwiftFileParserMock())
        let xcodeWorkspace = try parser.parseWorkspace(at: URL.Mock.exampleXcodeWorkspace)
        XCTAssertEqual(xcodeWorkspace.name, "ExampleWorkspace.xcworkspace")
    }

    func testParsesXcodeProjectPath() throws {
        let parser = XcodeWorkspaceParserLive(fileSystem: FileSystemMock(), packageSwiftFileParser: PackageSwiftFileParserMock())
        let xcodeWorkspace = try parser.parseWorkspace(at: URL.Mock.exampleXcodeWorkspace)
        XCTAssertTrue(xcodeWorkspace.xcodeProjectURL.lastPathComponent.hasSuffix("xcodeproj"))
    }

    func testParsesLocalSwiftPackages() throws {
        let parser = XcodeWorkspaceParserLive(fileSystem: FileSystemMock(), packageSwiftFileParser: PackageSwiftFileParserMock())
        let xcodeWorkspace = try parser.parseWorkspace(at: URL.Mock.exampleXcodeWorkspace)
        let packageA = xcodeWorkspace.localSwiftPackages.first { $0.name == "ExamplePackageA"}
        XCTAssertNotNil(packageA)
    }
}

private extension URL {
    enum Mock {
        static let exampleXcodeWorkspace = Bundle.module.url(forResource: "Example/ExampleWorkspace.xcworkspace", withExtension: nil)!
    }
}

private struct PackageSwiftFileParserMock: PackageSwiftFileParser {
    func parseFile(at fileURL: URL) throws -> PackageSwiftFile {
        return PackageSwiftFile(name: "ExamplePackageA", products: [], targets: [], dependencies: [])
    }
}
