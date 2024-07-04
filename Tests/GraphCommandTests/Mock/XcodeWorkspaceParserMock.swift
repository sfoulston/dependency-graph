import Foundation
import SwiftPackage
import XcodeWorkspace
import XcodeWorkspaceParser

struct XcodeWorkspaceParserMock: XcodeWorkspaceParser {
    func parseWorkspace(at fileURL: URL) throws -> XcodeWorkspace {
        return XcodeWorkspace(name: "Example", xcodeProjectURL: URL(string: "file://example.xcodeproj")!, localSwiftPackages: [])
    }
}
