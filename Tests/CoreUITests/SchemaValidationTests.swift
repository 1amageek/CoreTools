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

@Test func documentRequiresCoreUI1Schema() async throws {
    let decoder = SchemaDecoder()
    let documentJSON = """
    {
      "schema": "coreui/0",
      "message": "hello"
    }
    """

    do {
        _ = try decoder.decodeDocument(from: documentJSON)
        #expect(Bool(false))
    } catch let error as SchemaError {
        #expect(error == .unsupportedSchemaVersion("coreui/0"))
    }
}

@Test func documentWithoutUIIsAccepted() async throws {
    let decoder = SchemaDecoder()
    let documentJSON = """
    {
      "schema": "coreui/1",
      "message": "text only"
    }
    """

    let doc = try decoder.decodeDocument(from: documentJSON)

    #expect(doc.message == "text only")
    if doc.ui != nil {
        #expect(Bool(false))
    }
}

@Test func semanticTreeDocumentIsDecoded() async throws {
    let decoder = SchemaDecoder()
    let documentJSON = """
    {
      "schema": "coreui/1",
      "message": "map + calendar",
      "context": {
        "locale": "ja-JP",
        "timezone": "Asia/Tokyo"
      },
      "ui": {
        "body": {
          "vstack": {
            "spacing": "compact",
            "content": [
              {
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
              },
              {
                "section": {
                  "title": "Schedule",
                  "content": [
                    {
                      "view": {
                        "id": "calendar",
                        "type": "calendar.timeline",
                        "state": "content",
                        "data": {
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
                    }
                  ]
                }
              }
            ]
          }
        }
      }
    }
    """

    let doc = try decoder.decodeDocument(from: documentJSON)

    #expect(doc.schema == "coreui/1")
    #expect(doc.context?.timezone == "Asia/Tokyo")
    if let ui = doc.ui {
        #expect(ui.leafViews.count == 2)
        #expect(ui.leafViews[0].type == .mapSnapshot)
        #expect(ui.leafViews[1].type == .calendarTimeline)
    } else {
        #expect(Bool(false))
    }
}

@Test func mapRoutePayloadIsDecodedAsRouteView() async throws {
    let decoder = SchemaDecoder()
    let documentJSON = """
    {
      "schema": "coreui/1",
      "message": "route",
      "ui": {
        "body": {
          "view": {
            "id": "route",
            "type": "map.route",
            "state": "content",
            "data": {
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
        }
      }
    }
    """

    let doc = try decoder.decodeDocument(from: documentJSON)

    if let ui = doc.ui {
        #expect(ui.leafViews.count == 1)
        switch ui.leafViews[0].data {
        case .mapRoute:
            #expect(Bool(true))
        default:
            #expect(Bool(false))
        }
    } else {
        #expect(Bool(false))
    }
}

@Test func brokenViewFallsBackToSystemError() async throws {
    let decoder = SchemaDecoder()
    let documentJSON = """
    {
      "schema": "coreui/1",
      "message": "partial failure",
      "ui": {
        "body": {
          "vstack": {
            "content": [
              {
                "view": {
                  "id": "map",
                  "type": "map.snapshot",
                  "state": "content",
                  "data": {
                    "summary": ["invalid because center is missing"]
                  }
                }
              },
              {
                "view": {
                  "id": "loading",
                  "type": "system.loading",
                  "state": "loading",
                  "data": {
                    "message": "loading..."
                  }
                }
              }
            ]
          }
        }
      }
    }
    """

    let doc = try decoder.decodeDocument(from: documentJSON)

    if let ui = doc.ui {
        #expect(ui.leafViews.count == 2)

        switch ui.leafViews[0].data {
        case .schemaError:
            #expect(ui.leafViews[0].type == .systemError)
        default:
            #expect(Bool(false))
        }

        switch ui.leafViews[1].data {
        case .loadingState:
            #expect(ui.leafViews[1].type == .systemLoading)
        default:
            #expect(Bool(false))
        }
    } else {
        #expect(Bool(false))
    }
}
