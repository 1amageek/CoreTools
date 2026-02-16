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
      "summary": ["Tokyo"]
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

@Test func documentRequiresVersion11() async throws {
    let decoder = SchemaDecoder()
    let documentJSON = """
    {
      "schemaVersion": "1.0",
      "message": "hello"
    }
    """

    do {
        _ = try decoder.decodeDocument(from: documentJSON)
        #expect(Bool(false))
    } catch let error as SchemaError {
        #expect(error == .unsupportedSchemaVersion("1.0"))
    }
}

@Test func documentWithoutUIIsAccepted() async throws {
    let decoder = SchemaDecoder()
    let documentJSON = """
    {
      "schemaVersion": "1.1",
      "message": "text only"
    }
    """

    let doc = try decoder.decodeDocument(from: documentJSON)

    #expect(doc.message == "text only")
    if doc.ui != nil {
        #expect(Bool(false))
    }
}

@Test func multiViewDocumentIsDecoded() async throws {
    let decoder = SchemaDecoder()
    let documentJSON = """
    {
      "schemaVersion": "1.1",
      "message": "map + calendar",
      "ui": {
        "layout": "v",
        "views": [
          {
            "kind": "map",
            "payload": {
              "center": { "lat": 35.68, "lng": 139.76 },
              "pins": [
                {
                  "id": "me",
                  "title": "現在地",
                  "coord": { "lat": 35.68, "lng": 139.76 }
                }
              ]
            }
          },
          {
            "kind": "calendar",
            "payload": {
              "timezone": "Asia/Tokyo",
              "events": [
                {
                  "title": "通院",
                  "start": "2026-02-17T16:40:00+09:00",
                  "end": "2026-02-17T17:10:00+09:00",
                  "conflict": false
                }
              ]
            }
          }
        ]
      }
    }
    """

    let doc = try decoder.decodeDocument(from: documentJSON)

    #expect(doc.ui?.views.count == 2)
    if let ui = doc.ui {
        #expect(ui.layout == .vertical)
        #expect(ui.views[0].kind == .map)
        #expect(ui.views[1].kind == .calendar)
    }
}

@Test func mapRoutePayloadIsDecodedAsRouteView() async throws {
    let decoder = SchemaDecoder()
    let documentJSON = """
    {
      "schemaVersion": "1.1",
      "message": "route",
      "ui": {
        "views": [
          {
            "kind": "map",
            "payload": {
              "path": [
                { "lat": 35.68, "lng": 139.76 },
                { "lat": 35.69, "lng": 139.75 }
              ],
              "origin": {
                "id": "origin",
                "title": "現在地",
                "coord": { "lat": 35.68, "lng": 139.76 }
              },
              "destination": {
                "id": "destination",
                "title": "目的地",
                "coord": { "lat": 35.69, "lng": 139.75 }
              },
              "route": {
                "etaMin": 12,
                "distanceM": 3400
              },
              "steps": [
                { "stepID": "s1", "text": "直進する" }
              ]
            }
          }
        ]
      }
    }
    """

    let doc = try decoder.decodeDocument(from: documentJSON)

    if let ui = doc.ui {
        #expect(ui.views.count == 1)
        switch ui.views[0].payload {
        case .mapRoute:
            #expect(Bool(true))
        default:
            #expect(Bool(false))
        }
    } else {
        #expect(Bool(false))
    }
}

@Test func brokenViewFallsBackToSchemaError() async throws {
    let decoder = SchemaDecoder()
    let documentJSON = """
    {
      "schemaVersion": "1.1",
      "message": "partial failure",
      "ui": {
        "views": [
          {
            "kind": "map",
            "payload": {
              "summary": ["invalid because center is missing"]
            }
          },
          {
            "kind": "loading",
            "payload": {
              "message": "loading..."
            }
          }
        ]
      }
    }
    """

    let doc = try decoder.decodeDocument(from: documentJSON)

    if let ui = doc.ui {
        #expect(ui.views.count == 2)

        switch ui.views[0].payload {
        case .schemaError:
            #expect(Bool(true))
        default:
            #expect(Bool(false))
        }

        switch ui.views[1].payload {
        case .loadingState:
            #expect(Bool(true))
        default:
            #expect(Bool(false))
        }
    } else {
        #expect(Bool(false))
    }
}
