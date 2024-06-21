import FileSystem
import Foundation
import PathKit
import XMLCoder
import XcodeWorkspace
import SwiftPackage
import XcodeWorkspaceParser
import PackageSwiftFileParser

public struct XcodeWorkspaceParserLive: XcodeWorkspaceParser {
    private let fileSystem: FileSystem
    private let packageSwiftFileParser: PackageSwiftFileParser

    public init(fileSystem: FileSystem, packageSwiftFileParser: PackageSwiftFileParser) {
        self.fileSystem = fileSystem
        self.packageSwiftFileParser = packageSwiftFileParser
    }

    public func parseWorkspace(at fileURL: URL) throws -> XcodeWorkspace {
        let xcworkspaceDataFileURL = fileURL.appendingPathComponent("contents.xcworkspacedata")
        let rawXCWorkspaceData = try Data(contentsOf: xcworkspaceDataFileURL)
        let decoder = XMLDecoder()
        let workspace = try decoder.decode(XCWorkspaceData.self, from: rawXCWorkspaceData)

        let sourceRoot = fileURL.deletingLastPathComponent()
        let localSwiftPackages = try localSwiftPackages(in: workspace, atSourceRoot: sourceRoot)
        let xcodeProjectFileUrl = try findXcodeProjectFileUrl(in: workspace, for: sourceRoot)
        return XcodeWorkspace(
            name: fileURL.lastPathComponent,
            xcodeProjectURL: xcodeProjectFileUrl,
            localSwiftPackages: localSwiftPackages
        )
    }
}

private extension XcodeWorkspaceParserLive {
    func localSwiftPackages(in workspace: XCWorkspaceData, atSourceRoot sourceRoot: URL) throws -> [SwiftPackage] {
        let fileReferences = workspace.groups.flatMap {
            $0.fileReferences
        }
        return try fileReferences.compactMap { fileReference in
            guard let packageSwiftFileURL = fileReference.potentialPackageSwiftFileURL(forSourceRoot: sourceRoot) else {
                return nil
            }
            guard fileSystem.fileExists(at: packageSwiftFileURL) else {
                return nil
            }
            let swiftPackageInfo = try packageSwiftFileParser.parseFile(at: packageSwiftFileURL)
            let swiftPackageName = swiftPackageInfo.name
            return .local(name: swiftPackageName, fileURL: packageSwiftFileURL)
        }
    }

    enum XcodeWorkspaceParsingError: Error {
        case xcodeProjectNotFound

        var localizedDescription: String {
            return "Could not derive location of the Xcode project file from the given workspace."
        }
    }

    func findXcodeProjectFileUrl(in workspace: XCWorkspaceData, for sourceRoot: URL) throws -> URL {
        guard let xcodeProjectFilePath = workspace.xcodeprojPath else {
            throw XcodeWorkspaceParsingError.xcodeProjectNotFound
        }
        return sourceRoot.appendingPathComponent(xcodeProjectFilePath)
    }
}

private extension XCWorkspaceData.FileRef {
    func potentialPackageSwiftFileURL(forSourceRoot sourceRoot: URL) -> URL? {
        let path = self.location
        return ((sourceRoot as NSURL).appendingPathComponent(path) as? NSURL)?.appendingPathComponent("Package.swift")
    }
}
