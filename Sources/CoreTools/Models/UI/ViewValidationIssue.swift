@Generable
public struct ViewValidationIssue: Sendable {
    @Guide(description: "JSON path for the validation issue")
    public var path: String

    @Guide(description: "Human-readable validation failure reason")
    public var reason: String

    public init(path: String, reason: String) {
        self.path = path
        self.reason = reason
    }
}
