public struct UIPresentationHints: Codable, Sendable {
    public let preferredMode: String
    public let fullscreenAllowed: Bool
    public let minReadableHeight: Double?
    public let contentComplexity: String?
    public let contentRevision: String

    public init(
        preferredMode: String = "embeddedPreferred",
        fullscreenAllowed: Bool = true,
        minReadableHeight: Double? = nil,
        contentComplexity: String? = nil,
        contentRevision: String
    ) {
        self.preferredMode = preferredMode
        self.fullscreenAllowed = fullscreenAllowed
        self.minReadableHeight = minReadableHeight
        self.contentComplexity = contentComplexity
        self.contentRevision = contentRevision
    }

    public var preferredModeValue: UIPresentationPreferredMode {
        switch preferredMode {
        case UIPresentationPreferredMode.embeddedPreferred.rawValue:
            return .embeddedPreferred
        case UIPresentationPreferredMode.fullscreenPreferred.rawValue:
            return .fullscreenPreferred
        case UIPresentationPreferredMode.fullscreenRequired.rawValue:
            return .fullscreenRequired
        default:
            return .embeddedPreferred
        }
    }

    public var contentComplexityValue: UIContentComplexity {
        guard let contentComplexity else {
            return .medium
        }
        return UIContentComplexity(rawValue: contentComplexity) ?? .medium
    }
}
