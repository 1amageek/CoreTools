public struct ViewValidateTool: Tool {
    public let name = "view_validate"
    public let description = """
        Validate a CoreUI document JSON object before rendering it to the user.

        Use this after composing a CoreUI v1 semantic tree artifact. If validation fails, \
        call view_format once and validate again before showing the artifact.
        """

    @Generable
    public struct Arguments: Sendable {
        @Guide(description: "CoreUI document JSON to validate")
        public var documentJSON: String
    }

    public init() {}

    public func call(arguments: Arguments) async throws -> ViewValidationResult {
        let issues = ViewDocumentContract.validate(documentJSON: arguments.documentJSON)
        return ViewValidationResult(
            valid: issues.isEmpty,
            issues: issues,
            message: issues.isEmpty
                ? "CoreUI document is valid"
                : "CoreUI document has \(issues.count) validation issue(s)"
        )
    }
}

extension ViewValidateTool: ToolIconProviding {
    public var iconSystemName: String { "checkmark.shield" }
}
