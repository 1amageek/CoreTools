import Foundation

public struct ImageAssetPayload: Codable, Sendable {
    public let imageURL: String?
    public let placeholderSystemName: String

    public init(imageURL: String?, placeholderSystemName: String = "photo") {
        self.imageURL = imageURL
        self.placeholderSystemName = placeholderSystemName
    }
}

public struct ImagePreviewPayload: EmbeddedPayload {
    public let asset: ImageAssetPayload
    public let title: String
    public let subtitle: String?
    public let metadata: [String: String]

    public init(
        asset: ImageAssetPayload,
        title: String,
        subtitle: String? = nil,
        metadata: [String: String] = [:]
    ) {
        self.asset = asset
        self.title = title
        self.subtitle = subtitle
        self.metadata = metadata
    }

    public var hasMap: Bool { false }
    public var listCount: Int { metadata.count }
    public var formFieldCount: Int { 0 }
}
