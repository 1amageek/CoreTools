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
    let schema: String
    let message: String
    let context: CoreUIDocumentContext?
    let ui: RawUI?
}

private struct RawUI: Decodable {
    let body: RawNode
}

private indirect enum RawNode: Decodable {
    case vstack(RawStack)
    case hstack(RawStack)
    case section(RawSection)
    case view(RawView)

    private enum CodingKeys: String, CodingKey {
        case vstack
        case hstack
        case section
        case view
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let presentKeys = container.allKeys

        guard presentKeys.count == 1 else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: decoder.codingPath,
                    debugDescription: "CoreUI node must contain exactly one of vstack, hstack, section, or view"
                )
            )
        }

        if container.contains(.vstack) {
            self = .vstack(try container.decode(RawStack.self, forKey: .vstack))
        } else if container.contains(.hstack) {
            self = .hstack(try container.decode(RawStack.self, forKey: .hstack))
        } else if container.contains(.section) {
            self = .section(try container.decode(RawSection.self, forKey: .section))
        } else {
            self = .view(try container.decode(RawView.self, forKey: .view))
        }
    }
}

private struct RawStack: Decodable {
    let spacing: CoreUISpacing?
    let content: [RawNode]
}

private struct RawSection: Decodable {
    let title: String
    let subtitle: String?
    let content: [RawNode]
}

private struct RawView: Decodable {
    let id: String
    let type: String
    let state: CoreUIViewState
    let data: JSONValue
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
            #if DEBUG
            print("[SchemaDecoder] RawDocument decode error: \(error)")
            #endif
            throw SchemaError.invalidDocument
        }

        guard raw.schema == "coreui/1" else {
            throw SchemaError.unsupportedSchemaVersion(raw.schema)
        }

        guard let rawUI = raw.ui else {
            return CoreUIDocument(
                schema: raw.schema,
                message: raw.message,
                context: raw.context,
                ui: nil
            )
        }

        let ui = CoreUIDocumentUI(body: decodeNode(rawUI.body))
        return CoreUIDocument(
            schema: raw.schema,
            message: raw.message,
            context: raw.context,
            ui: ui
        )
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
        return try decodePayload(typeString: embeddedViewType, payloadData: payloadData)
    }

    private func decodeNode(_ raw: RawNode) -> CoreUINode {
        switch raw {
        case .vstack(let stack):
            return .vstack(
                CoreUIStack(
                    spacing: stack.spacing,
                    content: stack.content.map { decodeNode($0) }
                )
            )
        case .hstack(let stack):
            return .hstack(
                CoreUIStack(
                    spacing: stack.spacing,
                    content: stack.content.map { decodeNode($0) }
                )
            )
        case .section(let section):
            return .section(
                CoreUISection(
                    title: section.title,
                    subtitle: section.subtitle,
                    content: section.content.map { decodeNode($0) }
                )
            )
        case .view(let view):
            return .view(decodeView(view))
        }
    }

    private func decodeView(_ raw: RawView) -> CoreUIViewItem {
        let payloadData: Data
        do {
            payloadData = try encoder.encode(raw.data)
        } catch {
            return schemaErrorView(id: raw.id, reason: "data serialization failed")
        }

        guard let type = CoreUIViewType(rawValue: raw.type) else {
            return schemaErrorView(id: raw.id, reason: "unsupported type: \(raw.type)")
        }

        do {
            return CoreUIViewItem(
                id: raw.id,
                type: type,
                state: raw.state,
                data: try decodePayload(type: type, payloadData: payloadData),
                actions: raw.actions ?? []
            )
        } catch {
            return schemaErrorView(id: raw.id, reason: "data decode failed: \(error)")
        }
    }

    private func schemaErrorView(id: String, reason: String) -> CoreUIViewItem {
        CoreUIViewItem(
            id: id,
            type: .systemError,
            state: .error,
            data: .schemaError(SchemaErrorPayload(reason: reason)),
            actions: []
        )
    }

    private func decodePayload(type: CoreUIViewType, payloadData: Data) throws -> DecodedEmbeddedPayload {
        try decodePayload(typeString: type.rawValue, payloadData: payloadData)
    }

    private func decodePayload(typeString: String, payloadData: Data) throws -> DecodedEmbeddedPayload {
        do {
            switch typeString {
            case CoreUIViewType.mapSnapshot.rawValue, EmbeddedViewType.mapSnapshot.rawValue:
                let payload = try self.decoder.decode(MapSnapshotPayload.self, from: payloadData)
                return .mapSnapshot(payload)
            case CoreUIViewType.mapRoute.rawValue, EmbeddedViewType.mapRoute.rawValue:
                let payload = try self.decoder.decode(MapRoutePayload.self, from: payloadData)
                return .mapRoute(payload)
            case CoreUIViewType.imagePreview.rawValue, EmbeddedViewType.imagePreview.rawValue:
                let payload = try self.decoder.decode(ImagePreviewPayload.self, from: payloadData)
                return .imagePreview(payload)
            case CoreUIViewType.imageGallery.rawValue, EmbeddedViewType.imageGallery.rawValue:
                let payload = try self.decoder.decode(ImageGalleryPayload.self, from: payloadData)
                return .imageGallery(payload)
            case CoreUIViewType.calendarTimeline.rawValue, EmbeddedViewType.calendarTimeline.rawValue:
                let payload = try self.decoder.decode(CalendarTimelinePayload.self, from: payloadData)
                return .calendarTimeline(payload)
            case CoreUIViewType.healthTrend.rawValue, EmbeddedViewType.healthTrend.rawValue:
                let payload = try self.decoder.decode(HealthTrendPayload.self, from: payloadData)
                return .healthTrend(payload)
            case CoreUIViewType.placesList.rawValue, EmbeddedViewType.placeList.rawValue:
                let payload = try self.decoder.decode(PlaceListPayload.self, from: payloadData)
                return .placeList(payload)
            case CoreUIViewType.systemLoading.rawValue, EmbeddedViewType.loadingState.rawValue:
                let payload = try self.decoder.decode(LoadingStatePayload.self, from: payloadData)
                return .loadingState(payload)
            case CoreUIViewType.systemError.rawValue, EmbeddedViewType.schemaError.rawValue:
                let payload = try self.decoder.decode(SchemaErrorPayload.self, from: payloadData)
                return .schemaError(payload)
            default:
                throw SchemaError.unsupportedViewType(typeString)
            }
        } catch let error as SchemaError {
            throw error
        } catch {
            throw SchemaError.invalidPayload(typeString)
        }
    }
}
