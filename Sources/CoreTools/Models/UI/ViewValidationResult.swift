@Generable
public struct ViewValidationResult: Sendable, PromptRepresentable {
    @Guide(description: "Whether the view document is valid")
    public var valid: Bool

    @Guide(description: "Validation issues; empty when valid")
    public var issues: [ViewValidationIssue]

    @Guide(description: "Human-readable validation summary")
    public var message: String

    public init(valid: Bool, issues: [ViewValidationIssue], message: String) {
        self.valid = valid
        self.issues = issues
        self.message = message
    }
}
