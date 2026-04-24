#if canImport(ActivityKit) && os(iOS)
import ActivityKit
import Foundation

public struct ToolActivityManager: Sendable {

    public init() {}

    @discardableResult
    public func start(toolName: String) throws -> Activity<ToolActivityAttributes> {
        let attributes = ToolActivityAttributes()
        let state = ToolActivityAttributes.ContentState(
            toolName: toolName,
            status: .running
        )
        let content = ActivityContent(state: state, staleDate: nil)
        return try Activity<ToolActivityAttributes>.request(
            attributes: attributes,
            content: content,
            pushType: nil
        )
    }

    public func update(
        _ activity: Activity<ToolActivityAttributes>,
        toolName: String,
        status: ToolActivityStatus
    ) async {
        let state = ToolActivityAttributes.ContentState(
            toolName: toolName,
            status: status
        )
        let content = ActivityContent(state: state, staleDate: nil)
        await activity.update(content)
    }

    public func end(
        _ activity: Activity<ToolActivityAttributes>,
        toolName: String,
        status: ToolActivityStatus
    ) async {
        let state = ToolActivityAttributes.ContentState(
            toolName: toolName,
            status: status
        )
        let content = ActivityContent(state: state, staleDate: nil)
        await activity.end(content, dismissalPolicy: .after(Date(timeIntervalSinceNow: 4)))
    }
}
#endif
