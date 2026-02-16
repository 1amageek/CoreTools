public enum UIActionType: String, Codable, Sendable {
    case executeTool = "execute_tool"
    case retry
    case dismiss
    case openSettings = "open_settings"
}
