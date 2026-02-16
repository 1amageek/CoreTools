import CoreTools
import SwiftUI

public struct ScreenRegistry {
    public init() {}

    @MainActor
    public func render(
        header: EmbeddedViewHeader,
        payload: DecodedEmbeddedPayload,
        state: EmbeddedState,
        actionHandler: EmbeddedViewActionHandler,
        presentationDriver: PresentationDriver
    ) -> AnyView {
        switch payload {
        case .mapSnapshot(let value):
            return AnyView(
                EmbeddedScaffold(
                    header: header,
                    state: state,
                    actionHandler: actionHandler,
                    presentationDriver: presentationDriver
                ) {
                    MapSnapshotView(payload: value)
                }
            )
        case .imagePreview(let value):
            return AnyView(
                EmbeddedScaffold(
                    header: header,
                    state: state,
                    actionHandler: actionHandler,
                    presentationDriver: presentationDriver
                ) {
                    ImagePreviewView(payload: value)
                }
            )
        case .calendarTimeline(let value):
            return AnyView(
                EmbeddedScaffold(
                    header: header,
                    state: state,
                    actionHandler: actionHandler,
                    presentationDriver: presentationDriver
                ) {
                    CalendarTimelineView(payload: value)
                }
            )
        case .healthTrend(let value):
            return AnyView(
                EmbeddedScaffold(
                    header: header,
                    state: state,
                    actionHandler: actionHandler,
                    presentationDriver: presentationDriver
                ) {
                    HealthTrendView(payload: value)
                }
            )
        case .schemaError(let value):
            return AnyView(
                EmbeddedScaffold(
                    header: header,
                    state: state,
                    actionHandler: actionHandler,
                    presentationDriver: presentationDriver
                ) {
                    SchemaErrorView(payload: value)
                }
            )
        case .loadingState(let value):
            return AnyView(
                EmbeddedScaffold(
                    header: header,
                    state: state,
                    actionHandler: actionHandler,
                    presentationDriver: presentationDriver
                ) {
                    LoadingStateView(payload: value)
                }
            )
        }
    }
}
