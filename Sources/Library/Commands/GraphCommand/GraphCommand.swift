import DirectedGraphMapper
import Foundation
import PackageGraphBuilder
import PackageSwiftFileParser
import ProjectRootClassifier
import StdoutWriter
import XcodeProjectGraphBuilder
import XcodeProjectParser
import XcodeWorkspaceParser

private enum GraphCommandError: LocalizedError {
    case unknownProject(URL)

    var errorDescription: String? {
        switch self {
        case .unknownProject(let fileURL):
            return "Unknown project at \(fileURL.path)"
        }
    }
}

public struct GraphCommand {
    private let projectRootClassifier: ProjectRootClassifier
    private let packageSwiftFileParser: PackageSwiftFileParser
    private let xcodeProjectParser: XcodeProjectParser
    private let xcodeWorkspaceParser: XcodeWorkspaceParser
    private let packageGraphBuilder: PackageGraphBuilder
    private let xcodeProjectGraphBuilder: XcodeProjectGraphBuilder
    private let directedGraphWriterFactory: DirectedGraphWriterFactory

    public init(projectRootClassifier: ProjectRootClassifier,
                packageSwiftFileParser: PackageSwiftFileParser,
                xcodeProjectParser: XcodeProjectParser,
                xcodeWorkspaceParser: XcodeWorkspaceParser,
                packageGraphBuilder: PackageGraphBuilder,
                xcodeProjectGraphBuilder: XcodeProjectGraphBuilder,
                directedGraphWriterFactory: DirectedGraphWriterFactory) {
        self.projectRootClassifier = projectRootClassifier
        self.xcodeProjectParser = xcodeProjectParser
        self.xcodeWorkspaceParser = xcodeWorkspaceParser
        self.packageSwiftFileParser = packageSwiftFileParser
        self.packageGraphBuilder = packageGraphBuilder
        self.xcodeProjectGraphBuilder = xcodeProjectGraphBuilder
        self.directedGraphWriterFactory = directedGraphWriterFactory
    }

    public func run(withInput input: String, syntax: Syntax) throws {
        let fileURL = NSURL.fileURL(withPath: input)
        let projectRoot = projectRootClassifier.classifyProject(at: fileURL)
        let directedGraphWriter = directedGraphWriterFactory.writer(for: syntax)
        switch projectRoot {
        case .xcodeproj(let xcodeprojFileURL):
            let xcodeProject = try xcodeProjectParser.parseProject(at: xcodeprojFileURL)
            let graph = try xcodeProjectGraphBuilder.buildGraph(from: xcodeProject)
            try directedGraphWriter.write(graph)
        case .xcworkspace(let xcworkspaceFileURL):
            let xcodeWorkspace = try xcodeWorkspaceParser.parseWorkspace(at: xcworkspaceFileURL)
            let xcodeProjectFileURL = xcodeWorkspace.xcodeProjectURL
            var xcodeProject = try xcodeProjectParser.parseProject(at: xcodeProjectFileURL)
            xcodeProject.addSwiftPackages(xcodeWorkspace.localSwiftPackages)
            let graph = try xcodeProjectGraphBuilder.buildGraph(from: xcodeProject)
            try directedGraphWriter.write(graph)
        case .packageSwiftFile(let packageSwiftFileURL):
            let packageSwiftFile = try packageSwiftFileParser.parseFile(at: packageSwiftFileURL)
            let graph = try packageGraphBuilder.buildGraph(from: packageSwiftFile)
            try directedGraphWriter.write(graph)
        case .unknown:
            throw GraphCommandError.unknownProject(fileURL)
        }
    }
}
