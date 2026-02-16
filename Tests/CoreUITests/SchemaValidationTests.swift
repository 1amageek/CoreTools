import Testing
@testable import CoreUI

@Test func headerRequiresVersion10() async throws {
    let decoder = SchemaDecoder()
    let headerJSON = """
    {
      "schemaVersion": "2.0",
      "embeddedViewType": "map_snapshot",
      "containerID": "container-1",
      "title": "Current Location",
      "subtitle": "Share",
      "riskLevel": "high",
      "confirmationStyle": "double",
      "presentationHints": {
        "preferredMode": "embeddedPreferred",
        "fullscreenAllowed": true,
        "minReadableHeight": 320,
        "contentComplexity": "high",
        "contentRevision": "r1"
      }
    }
    """

    do {
        _ = try decoder.decodeHeader(from: headerJSON)
        #expect(Bool(false))
    } catch let error as SchemaError {
        #expect(error == .unsupportedSchemaVersion("2.0"))
    }
}

@Test func missingPresentationHintsFailsDecoding() async throws {
    let decoder = SchemaDecoder()
    let headerJSON = """
    {
      "schemaVersion": "1.0",
      "embeddedViewType": "map_snapshot",
      "containerID": "container-1",
      "title": "Current Location",
      "subtitle": "Share",
      "riskLevel": "high",
      "confirmationStyle": "double"
    }
    """

    do {
        _ = try decoder.decodeHeader(from: headerJSON)
        #expect(Bool(false))
    } catch let error as SchemaError {
        #expect(error == .invalidHeader)
    }
}

@Test func invalidPayloadBecomesSchemaError() async throws {
    let decoder = SchemaDecoder()
    let payloadJSON = """
    {
      "summaryLines": ["Tokyo"]
    }
    """

    do {
        _ = try decoder.decodePayload(
            embeddedViewType: "map_snapshot",
            payloadJSON: payloadJSON
        )
        #expect(Bool(false))
    } catch let error as SchemaError {
        #expect(error == .invalidPayload("map_snapshot"))
    }
}
