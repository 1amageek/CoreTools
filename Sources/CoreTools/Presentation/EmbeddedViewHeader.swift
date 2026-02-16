public struct EmbeddedViewHeader: Codable, Sendable {
    public let schemaVersion: String
    public let embeddedViewType: String
    public let containerID: String
    public let title: String
    public let subtitle: String?
    public let riskLevel: String
    public let confirmationStyle: String
    public let presentationHints: UIPresentationHints
    public let primaryAction: UIActionDescriptor?
    public let secondaryAction: UIActionDescriptor?

    public init(
        schemaVersion: String = "1.0",
        embeddedViewType: String,
        containerID: String,
        title: String,
        subtitle: String? = nil,
        riskLevel: String,
        confirmationStyle: String,
        presentationHints: UIPresentationHints,
        primaryAction: UIActionDescriptor? = nil,
        secondaryAction: UIActionDescriptor? = nil
    ) {
        self.schemaVersion = schemaVersion
        self.embeddedViewType = embeddedViewType
        self.containerID = containerID
        self.title = title
        self.subtitle = subtitle
        self.riskLevel = riskLevel
        self.confirmationStyle = confirmationStyle
        self.presentationHints = presentationHints
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
    }
}
