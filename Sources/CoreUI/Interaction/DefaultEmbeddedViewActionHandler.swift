import CoreTools

public actor DefaultEmbeddedViewActionHandler: EmbeddedViewActionHandler {
    public private(set) var handledActions: [String: UIActionDescriptor]

    public init() {
        self.handledActions = [:]
    }

    public func handle(containerID: String, action: UIActionDescriptor) async -> ActionResult {
        self.handledActions[containerID] = action
        let isSuccess = action.actionTypeValue != .retry
        let summary = isSuccess ? "Action completed" : "Action requires retry"
        return ActionResult(
            containerID: containerID,
            actionID: action.actionID,
            success: isSuccess,
            message: summary
        )
    }
}
