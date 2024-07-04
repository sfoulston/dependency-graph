import Foundation
import XcodeWorkspace

public protocol XcodeWorkspaceParser {
    func parseWorkspace(at fileURL: URL) throws -> XcodeWorkspace
}
