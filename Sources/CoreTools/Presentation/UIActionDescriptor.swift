public struct UIActionDescriptor: Codable, Sendable {
    public let actionType: String
    public let actionID: String
    public let toolName: String?
    public let argumentsJSON: String?

    public init(
        actionType: String,
        actionID: String,
        toolName: String? = nil,
        argumentsJSON: String? = nil
    ) {
        self.actionType = actionType
        self.actionID = actionID
        self.toolName = toolName
        self.argumentsJSON = argumentsJSON
    }

    public var actionTypeValue: UIActionType {
        UIActionType(rawValue: actionType) ?? .dismiss
    }
}
