#if canImport(ActivityKit) && os(iOS)
import ActivityKit

public struct ToolActivityAttributes: ActivityAttributes {

    public struct ContentState: Codable, Hashable {
        public var toolName: String
        public var status: ToolActivityStatus

        public init(toolName: String, status: ToolActivityStatus) {
            self.toolName = toolName
            self.status = status
        }
    }

    public init() {}
}
#endif

public enum ToolActivityStatus: String, Codable, Hashable, Sendable {
    case running
    case completed
    case failed
}
