import CoreTools
import Foundation

public enum SchemaError: Error, Equatable {
    case invalidHeader
    case invalidDocument
    case unsupportedSchemaVersion(String)
    case unsupportedViewType(String)
    case invalidPayload(String)
}

private struct RawDocument: Decodable {
    let schemaVersion: String
    let message: String
    let ui: RawUI?
}

private struct RawUI: Decodable {
    let layout: CoreUILayout?
    let views: [RawView]
    let actions: [CoreUIAction]?
}

private struct RawView: Decodable {
    let kind: String
    let payload: JSONValue
    let actions: [CoreUIAction]?
}

public struct SchemaDecoder {
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    public init(decoder: JSONDecoder = JSONDecoder(), encoder: JSONEncoder = JSONEncoder()) {
        self.decoder = decoder
        self.encoder = encoder
    }

    public func decodeDocument(from documentJSON: String) throws -> CoreUIDocument {
        let data = Data(documentJSON.utf8)
        let raw: RawDocument

        do {
            raw = try decoder.decode(RawDocument.self, from: data)
        } catch {
            throw SchemaError.invalidDocument
        }

        guard raw.schemaVersion == "1.1" else {
            throw SchemaError.unsupportedSchemaVersion(raw.schemaVersion)
        }

        guard let rawUI = raw.ui else {
            return CoreUIDocument(schemaVersion: raw.schemaVersion, message: raw.message, ui: nil)
        }

        var renderedViews: [CoreUIViewItem] = []

        for (index, rawView) in rawUI.views.enumerated() {
            let payloadData: Data
            do {
                payloadData = try encoder.encode(rawView.payload)
            } catch {
                let fallback = CoreUIViewItem(
                    id: "view-\(index)",
                    kind: .schemaError,
                    payload: .schemaError(SchemaErrorPayload(reason: "payload serialization failed")),
                    actions: rawView.actions ?? []
                )
                renderedViews.append(fallback)
                continue
            }

            let kind = CoreUIViewKind(rawValue: rawView.kind)

            let decodedPayload: DecodedEmbeddedPayload
            if let kind {
                do {
                    decodedPayload = try decodePayload(kind: kind, payloadData: payloadData)
                } catch {
                    decodedPayload = .schemaError(
                        SchemaErrorPayload(reason: "payload decode failed: \(error)")
                    )
                }
            } else {
                decodedPayload = .schemaError(
                    SchemaErrorPayload(reason: "unsupported kind: \(rawView.kind)")
                )
            }

            renderedViews.append(
                CoreUIViewItem(
                    id: "view-\(index)",
                    kind: kind ?? .schemaError,
                    payload: decodedPayload,
                    actions: rawView.actions ?? []
                )
            )
        }

        let ui = CoreUIDocumentUI(
            layout: rawUI.layout ?? .vertical,
            views: renderedViews,
            actions: rawUI.actions ?? []
        )

        return CoreUIDocument(schemaVersion: raw.schemaVersion, message: raw.message, ui: ui)
    }

    public func decodeHeader(from headerJSON: String) throws -> EmbeddedViewHeader {
        let headerData = Data(headerJSON.utf8)

        do {
            let header = try self.decoder.decode(EmbeddedViewHeader.self, from: headerData)
            guard header.schemaVersion == "1.0" else {
                throw SchemaError.unsupportedSchemaVersion(header.schemaVersion)
            }
            return header
        } catch let error as SchemaError {
            throw error
        } catch {
            throw SchemaError.invalidHeader
        }
    }

    public func decodePayload(
        embeddedViewType: String,
        payloadJSON: String
    ) throws -> DecodedEmbeddedPayload {
        let payloadData = Data(payloadJSON.utf8)
        return try decodePayload(kindString: embeddedViewType, payloadData: payloadData)
    }

    private func decodePayload(kind: CoreUIViewKind, payloadData: Data) throws -> DecodedEmbeddedPayload {
        return try decodePayload(kindString: kind.rawValue, payloadData: payloadData)
    }

    private func decodePayload(kindString: String, payloadData: Data) throws -> DecodedEmbeddedPayload {
        do {
            switch kindString {
            case "map", EmbeddedViewType.mapSnapshot.rawValue, EmbeddedViewType.mapRoute.rawValue:
                do {
                    let payload = try self.decoder.decode(MapRoutePayload.self, from: payloadData)
                    return .mapRoute(payload)
                } catch {
                    let payload = try self.decoder.decode(MapSnapshotPayload.self, from: payloadData)
                    return .mapSnapshot(payload)
                }
            case "image", EmbeddedViewType.imagePreview.rawValue:
                let payload = try self.decoder.decode(ImagePreviewPayload.self, from: payloadData)
                return .imagePreview(payload)
            case "calendar", EmbeddedViewType.calendarTimeline.rawValue:
                let payload = try self.decoder.decode(CalendarTimelinePayload.self, from: payloadData)
                return .calendarTimeline(payload)
            case "health", EmbeddedViewType.healthTrend.rawValue:
                let payload = try self.decoder.decode(HealthTrendPayload.self, from: payloadData)
                return .healthTrend(payload)
            case "loading", EmbeddedViewType.loadingState.rawValue:
                let payload = try self.decoder.decode(LoadingStatePayload.self, from: payloadData)
                return .loadingState(payload)
            case "schema_error", EmbeddedViewType.schemaError.rawValue:
                let payload = try self.decoder.decode(SchemaErrorPayload.self, from: payloadData)
                return .schemaError(payload)
            default:
                throw SchemaError.unsupportedViewType(kindString)
            }
        } catch let error as SchemaError {
            throw error
        } catch {
            throw SchemaError.invalidPayload(kindString)
        }
    }
}
