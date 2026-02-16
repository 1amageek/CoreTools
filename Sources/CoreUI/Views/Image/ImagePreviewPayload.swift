import Foundation

public struct ImagePreviewPayload: EmbeddedPayload {
    public let url: String?
    public let placeholder: String?
    public let title: String?
    public let subtitle: String?
    public let metadata: [String: String]

    enum CodingKeys: String, CodingKey {
        case url
        case placeholder
        case title
        case subtitle
        case meta
        case metadata
    }

    public init(
        url: String?,
        placeholder: String? = nil,
        title: String? = nil,
        subtitle: String? = nil,
        metadata: [String: String] = [:]
    ) {
        self.url = url
        self.placeholder = placeholder
        self.title = title
        self.subtitle = subtitle
        self.metadata = metadata
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.url = try container.decodeIfPresent(String.self, forKey: .url)
        self.placeholder = try container.decodeIfPresent(String.self, forKey: .placeholder)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)

        if let meta = try container.decodeIfPresent([String: String].self, forKey: .meta) {
            self.metadata = meta
        } else {
            self.metadata = try container.decodeIfPresent([String: String].self, forKey: .metadata) ?? [:]
        }

        if self.url == nil && self.placeholder == nil {
            throw DecodingError.dataCorruptedError(
                forKey: .url,
                in: container,
                debugDescription: "Either 'url' or 'placeholder' must be present."
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(url, forKey: .url)
        try container.encodeIfPresent(placeholder, forKey: .placeholder)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(subtitle, forKey: .subtitle)
        try container.encode(metadata, forKey: .meta)
    }

    public var hasMap: Bool { false }
    public var listCount: Int { metadata.count }
    public var formFieldCount: Int { 0 }
}
