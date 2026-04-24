import Testing
@testable import CoreTools

@Suite("ViewValidateTool Tests")
struct ViewValidateToolTests {
    @Test("Accepts valid minimal map snapshot document")
    func validDocument() async throws {
        let tool = ViewValidateTool()
        let input = """
        {
          "schema": "coreui/1",
          "message": "ok",
          "ui": {
            "body": {
              "view": {
                "id": "map",
                "type": "map.snapshot",
                "state": "content",
                "data": {
                  "center": { "lat": 35.68, "lng": 139.76 },
                  "pins": [
                    {
                      "id": "me",
                      "title": "現在地",
                      "coord": { "lat": 35.68, "lng": 139.76 }
                    }
                  ]
                }
              }
            }
          }
        }
        """
        let args = try ViewValidateTool.Arguments(GeneratedContent(properties: [
            "documentJSON": input
        ]))
        let result = try await tool.call(arguments: args)

        #expect(result.valid)
        #expect(result.issues.isEmpty)
    }

    @Test("Reports issues for invalid document")
    func invalidDocument() async throws {
        let tool = ViewValidateTool()
        let input = """
        {
          "schema": "coreui/0",
          "message": "bad",
          "ui": {
            "body": {
              "view": {
                "id": "map",
                "type": "map.snapshot",
                "state": "content",
                "data": {
                  "center": { "lat": 35.68, "lng": 139.76 }
                }
              }
            }
          }
        }
        """
        let args = try ViewValidateTool.Arguments(GeneratedContent(properties: [
            "documentJSON": input
        ]))
        let result = try await tool.call(arguments: args)

        #expect(!result.valid)
        #expect(!result.issues.isEmpty)
    }

    @Test("Accepts empty calendar document for clear schedule UX")
    func emptyCalendarDocument() async throws {
        let tool = ViewValidateTool()
        let input = """
        {
          "schema": "coreui/1",
          "message": "No events found",
          "ui": {
            "body": {
              "view": {
                "id": "calendar",
                "type": "calendar.timeline",
                "state": "empty",
                "data": {
                  "timezone": "Asia/Tokyo",
                  "events": []
                }
              }
            }
          }
        }
        """
        let args = try ViewValidateTool.Arguments(GeneratedContent(properties: [
            "documentJSON": input
        ]))
        let result = try await tool.call(arguments: args)

        #expect(result.valid)
        #expect(result.issues.isEmpty)
    }

    @Test("Accepts nested section with places document")
    func placesDocument() async throws {
        let tool = ViewValidateTool()
        let input = """
        {
          "schema": "coreui/1",
          "message": "Found nearby cafes",
          "ui": {
            "body": {
              "section": {
                "title": "Nearby",
                "content": [
                  {
                    "view": {
                      "id": "places",
                      "type": "places.list",
                      "state": "content",
                      "data": {
                        "places": [
                          {
                            "id": "place-1",
                            "name": "Cafe",
                            "address": "Tokyo",
                            "category": "cafe"
                          }
                        ]
                      }
                    }
                  }
                ]
              }
            }
          }
        }
        """
        let args = try ViewValidateTool.Arguments(GeneratedContent(properties: [
            "documentJSON": input
        ]))
        let result = try await tool.call(arguments: args)

        #expect(result.valid)
        #expect(result.issues.isEmpty)
    }
}
