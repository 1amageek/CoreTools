@Generable
public struct ViewFormatResult: Sendable, PromptRepresentable {
    @Guide(description: "Normalized CoreUI document JSON")
    public var documentJSON: String

    @Guide(description: "Warnings emitted while normalizing the document")
    public var warnings: [String]

    @Guide(description: "Whether the input document was changed")
    public var normalized: Bool

    @Guide(description: "Human-readable formatting summary")
    public var message: String

    public init(documentJSON: String, warnings: [String], normalized: Bool, message: String) {
        self.documentJSON = documentJSON
        self.warnings = warnings
        self.normalized = normalized
        self.message = message
    }
}
