import Foundation

public struct SchemaErrorPayload: EmbeddedPayload {
    public let reason: String

    public init(reason: String) {
        self.reason = reason
    }

    public var hasMap: Bool { false }
    public var listCount: Int { 0 }
    public var formFieldCount: Int { 0 }
}
