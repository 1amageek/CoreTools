public enum DecodedEmbeddedPayload: Sendable {
    case mapSnapshot(MapSnapshotPayload)
    case mapRoute(MapRoutePayload)
    case imagePreview(ImagePreviewPayload)
    case calendarTimeline(CalendarTimelinePayload)
    case healthTrend(HealthTrendPayload)
    case schemaError(SchemaErrorPayload)
    case loadingState(LoadingStatePayload)

    public var metrics: (hasMap: Bool, listCount: Int, formFieldCount: Int) {
        switch self {
        case .mapSnapshot(let payload):
            return (payload.hasMap, payload.listCount, payload.formFieldCount)
        case .mapRoute(let payload):
            return (payload.hasMap, payload.listCount, payload.formFieldCount)
        case .imagePreview(let payload):
            return (payload.hasMap, payload.listCount, payload.formFieldCount)
        case .calendarTimeline(let payload):
            return (payload.hasMap, payload.listCount, payload.formFieldCount)
        case .healthTrend(let payload):
            return (payload.hasMap, payload.listCount, payload.formFieldCount)
        case .schemaError(let payload):
            return (payload.hasMap, payload.listCount, payload.formFieldCount)
        case .loadingState(let payload):
            return (payload.hasMap, payload.listCount, payload.formFieldCount)
        }
    }

    public var kind: CoreUIViewKind {
        switch self {
        case .mapSnapshot:
            return .map
        case .mapRoute:
            return .map
        case .imagePreview:
            return .image
        case .calendarTimeline:
            return .calendar
        case .healthTrend:
            return .health
        case .schemaError:
            return .schemaError
        case .loadingState:
            return .loading
        }
    }
}
