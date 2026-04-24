public struct ViewFormatTool: Tool {
    public let name = "view_format"
    public let description = """
        Normalize a CoreUI document JSON object into a renderable shape.

        Use this before returning a CoreUI artifact when the document may be incomplete, \
        uses unsupported aliases, or was generated from natural language. The tool expects \
        the CoreUI v1 semantic tree format and replaces invalid nodes with system.error views.
        """

    @Generable
    public struct Arguments: Sendable {
        @Guide(description: "CoreUI document JSON to normalize")
        public var documentJSON: String
    }

    public init() {}

    public func call(arguments: Arguments) async throws -> ViewFormatResult {
        let result = try ViewDocumentContract.normalize(documentJSON: arguments.documentJSON)
        return ViewFormatResult(
            documentJSON: result.documentJSON,
            warnings: result.warnings,
            normalized: result.normalized,
            message: result.normalized
                ? "CoreUI document normalized with \(result.warnings.count) warning(s)"
                : "CoreUI document already matched the supported format"
        )
    }
}

extension ViewFormatTool: ToolIconProviding {
    public var iconSystemName: String { "wand.and.sparkles" }
}
