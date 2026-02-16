import Foundation

public struct LoadingStatePayload: EmbeddedPayload {
    public let message: String

    public init(message: String) {
        self.message = message
    }

    public var hasMap: Bool { false }
    public var listCount: Int { 0 }
    public var formFieldCount: Int { 0 }
}
