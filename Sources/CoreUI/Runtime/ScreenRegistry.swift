import SwiftUI

public struct ScreenRegistry {
    public init() {}

    @MainActor
    public func render(payload: DecodedEmbeddedPayload) -> AnyView {
        switch payload {
        case .mapSnapshot(let value):
            return AnyView(MapSnapshotView(payload: value))
        case .mapRoute(let value):
            return AnyView(MapRouteView(payload: value))
        case .imagePreview(let value):
            return AnyView(ImagePreviewView(payload: value))
        case .calendarTimeline(let value):
            return AnyView(CalendarTimelineView(payload: value))
        case .healthTrend(let value):
            return AnyView(HealthTrendView(payload: value))
        case .schemaError(let value):
            return AnyView(SchemaErrorView(payload: value))
        case .loadingState(let value):
            return AnyView(LoadingStateView(payload: value))
        }
    }
}
