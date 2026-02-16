import CoreTools

public struct ActionResult: Sendable {
    public let containerID: String
    public let actionID: String
    public let success: Bool
    public let message: String

    public init(containerID: String, actionID: String, success: Bool, message: String) {
        self.containerID = containerID
        self.actionID = actionID
        self.success = success
        self.message = message
    }
}

public protocol EmbeddedViewActionHandler: Sendable {
    func handle(containerID: String, action: UIActionDescriptor) async -> ActionResult
}
