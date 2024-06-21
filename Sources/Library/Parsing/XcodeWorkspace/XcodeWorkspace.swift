import Foundation
import SwiftPackage

public struct XcodeWorkspace: Equatable {
    public let name: String
    public let xcodeProjectURL: URL
    public let localSwiftPackages: [SwiftPackage]

    public init(name: String, xcodeProjectURL: URL, localSwiftPackages: [SwiftPackage]) {
        self.name = name
        self.xcodeProjectURL = xcodeProjectURL
        self.localSwiftPackages = localSwiftPackages
    }
}
