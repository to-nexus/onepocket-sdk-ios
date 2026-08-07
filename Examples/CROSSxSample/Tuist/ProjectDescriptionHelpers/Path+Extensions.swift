import ProjectDescription

extension Path {
    static func relativeToRoot(_ path: String) -> Self {
        return .relativeToManifest("../../\(path)")
    }
}
