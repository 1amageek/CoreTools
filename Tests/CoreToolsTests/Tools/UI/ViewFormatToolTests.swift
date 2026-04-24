import Foundation
import Testing
@testable import CoreTools

@Suite("ViewFormatTool Tests")
struct ViewFormatToolTests {
    @Test("Normalizes unsupported schema and malformed semantic node")
    func normalizesUnsupportedFields() async throws {
        let tool = ViewFormatTool()
        let input = """
        {
          "schema": "coreui/0",
          "message": "test",
          "ui": {
            "body": {
              "view": {
                "type": "unknown",
                "data": {}
              }
            }
          }
        }
        """

        let args = try ViewFormatTool.Arguments(GeneratedContent(properties: [
            "documentJSON": input
        ]))
        let result = try await tool.call(arguments: args)

        #expect(result.normalized)
        #expect(!result.warnings.isEmpty)

        let data = Data(result.documentJSON.utf8)
        let object = try JSONSerialization.jsonObject(with: data)
        guard let root = object as? [String: Any] else {
            #expect(Bool(false))
            return
        }

        #expect(root["schema"] as? String == "coreui/1")
        if let ui = root["ui"] as? [String: Any],
           let body = ui["body"] as? [String: Any],
           let view = body["view"] as? [String: Any] {
            #expect(view["type"] as? String == "system.error")
            #expect(view["state"] as? String == "error")
            #expect(view["id"] as? String == "view-0")
        } else {
            #expect(Bool(false))
        }
    }
}
