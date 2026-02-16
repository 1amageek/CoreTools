import Foundation

public enum CoreToolsError: Error, Sendable {
    case permissionDenied(framework: String, detail: String)
    case serviceUnavailable(framework: String)
    case invalidInput(parameter: String, reason: String)
    case timeout(operation: String, seconds: Double)
    case notFound(resource: String)
    case operationFailed(operation: String, underlyingError: any Error)
}
