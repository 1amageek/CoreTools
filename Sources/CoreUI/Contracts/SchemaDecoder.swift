import CoreTools
import Foundation

public enum SchemaError: Error, Equatable {
    case invalidHeader
    case unsupportedSchemaVersion(String)
    case unsupportedViewType(String)
    case invalidPayload(String)
}

public struct SchemaDecoder {
    private let decoder: JSONDecoder

    public init(decoder: JSONDecoder = JSONDecoder()) {
        self.decoder = decoder
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
        guard let supportedType = EmbeddedViewType(rawValue: embeddedViewType) else {
            throw SchemaError.unsupportedViewType(embeddedViewType)
        }

        let payloadData = Data(payloadJSON.utf8)

        do {
            switch supportedType {
            case .mapSnapshot:
                let payload = try self.decoder.decode(MapSnapshotPayload.self, from: payloadData)
                return .mapSnapshot(payload)
            case .imagePreview:
                let payload = try self.decoder.decode(ImagePreviewPayload.self, from: payloadData)
                return .imagePreview(payload)
            case .calendarTimeline:
                let payload = try self.decoder.decode(CalendarTimelinePayload.self, from: payloadData)
                return .calendarTimeline(payload)
            case .healthTrend:
                let payload = try self.decoder.decode(HealthTrendPayload.self, from: payloadData)
                return .healthTrend(payload)
            case .schemaError:
                let payload = try self.decoder.decode(SchemaErrorPayload.self, from: payloadData)
                return .schemaError(payload)
            case .loadingState:
                let payload = try self.decoder.decode(LoadingStatePayload.self, from: payloadData)
                return .loadingState(payload)
            }
        } catch {
            throw SchemaError.invalidPayload(embeddedViewType)
        }
    }
}
