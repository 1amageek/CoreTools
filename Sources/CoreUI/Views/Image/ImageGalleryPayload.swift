import Foundation

public struct ImageGalleryItem: Codable, Sendable, Identifiable {
    public let id: String
    public let url: String
    public let title: String?
    public let caption: String?

    public init(
        id: String,
        url: String,
        title: String? = nil,
        caption: String? = nil
    ) {
        self.id = id
        self.url = url
        self.title = title
        self.caption = caption
    }
}

public struct ImageGalleryPayload: EmbeddedPayload {
    public let images: [ImageGalleryItem]

    public init(images: [ImageGalleryItem]) {
        self.images = images
    }

    public var hasMap: Bool { false }
    public var listCount: Int { images.count }
    public var formFieldCount: Int { 0 }
}
