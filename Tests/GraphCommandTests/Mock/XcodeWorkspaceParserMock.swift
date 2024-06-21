import Foundation
import XcodeWorkspace
import XcodeWorkspaceParser
import SwiftPackage

struct XcodeWorkspaceParserMock: XcodeWorkspaceParser {
    func parseWorkspace(at fileURL: URL) throws -> XcodeWorkspace {
        return XcodeWorkspace(name: "Example", xcodeProjectURL: URL(string: "file://example.xcodeproj")!, localSwiftPackages: [])
    }
}
