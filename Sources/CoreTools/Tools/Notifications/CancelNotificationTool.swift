
public struct CancelNotificationTool: Tool {
    public let name = "notification_cancel"
    public let description = "Cancel one or more pending notifications by identifier"

    @Generable
    public struct Arguments: Sendable {
        @Guide(description: "Identifiers of notifications to cancel")
        public var identifiers: [String]
    }

    private let service: any NotificationServiceProtocol

    public init(service: any NotificationServiceProtocol) {
        self.service = service
    }

    public func call(arguments: Arguments) async throws -> CancelNotificationResult {
        try await service.cancel(identifiers: arguments.identifiers)
        return CancelNotificationResult(
            cancelledIdentifiers: arguments.identifiers,
            message: "Cancelled \(arguments.identifiers.count) notification(s)"
        )
    }
}
