import Foundation

struct XCWorkspaceData: Decodable {
    let groups: [Group]
    let fileReferences: [FileRef]

    var xcodeprojPath: String? {
        var path: String?
        for group in groups {
            for fileRef in group.fileReferences where fileRef.location.hasSuffix(".xcodeproj") {
                path = fileRef.location
            }
        }
        // Simpler workspaces contain only file references.
        if path == nil {
            for fileRef in fileReferences where fileRef.location.hasSuffix(".xcodeproj") {
                path = fileRef.location.replacingOccurrences(of: "container:", with: "")
            }
        }
        return path
    }

    enum CodingKeys: String, CodingKey {
        case groups = "Group"
        case fileReferences = "FileRef"
    }

    struct Group: Decodable {
        let name: String
        let location: String
        var fileReferences: [FileRef] {
            _fileReferences.map {
                let newLocation = $0.location.replacingOccurrences(of: "group:", with: "\(name)/")
                let newFileRef = FileRef(location: newLocation)
                return newFileRef
            }
        }
        private let _fileReferences: [FileRef]

        enum CodingKeys: String, CodingKey {
            case name = "name"
            case location = "location"
            case _fileReferences = "FileRef"
        }
    }

    struct FileRef: Decodable {
        let location: String
    }
}
