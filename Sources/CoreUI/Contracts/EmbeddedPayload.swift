import Foundation

public protocol EmbeddedPayload: Codable, Sendable {
    var hasMap: Bool { get }
    var listCount: Int { get }
    var formFieldCount: Int { get }
}
