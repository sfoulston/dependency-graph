import Foundation
import SwiftPackage

public struct XcodeProject: Equatable {
    public let name: String
    public let targets: [Target]
    public var swiftPackages: [SwiftPackage]

    public init(name: String, targets: [Target] = [], swiftPackages: [SwiftPackage] = []) {
        self.name = name
        self.targets = targets
        self.swiftPackages = swiftPackages
    }

    public mutating func addSwiftPackages(_ swiftPackages: [SwiftPackage]) {
        self.swiftPackages.append(contentsOf: swiftPackages)
    }
}
