import Foundation

public enum ProjectRoot: Equatable {
    case xcodeproj(URL)
    case xcworkspace(URL)
    case packageSwiftFile(URL)
    case unknown
}
