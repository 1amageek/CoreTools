import SwiftUI

private enum LayoutPreviewDependencies {
    static let actionHandler = DefaultEmbeddedViewActionHandler()
    static let presentationDriver = NoopPresentationDriver()
}

private enum LayoutPreviewFixtures {
    static let mapView = CoreUIViewItem(
        id: "view-map",
        kind: .map,
        payload: .mapSnapshot(
            MapSnapshotPayload(
                center: CoordinatePayload(latitude: 35.681236, longitude: 139.767125),
                annotations: [
                    MapAnnotationPayload(
                        id: "current",
                        title: "現在地",
                        coordinate: CoordinatePayload(latitude: 35.681236, longitude: 139.767125)
                    ),
                    MapAnnotationPayload(
                        id: "clinic",
                        title: "赤坂クリニック",
                        coordinate: CoordinatePayload(latitude: 35.6721, longitude: 139.7362)
                    ),
                ],
                routeSummary: MapRouteSummaryPayload(
                    originLabel: "現在地",
                    destinationLabel: "赤坂クリニック",
                    distanceMeters: 5200,
                    etaMinutes: 17
                ),
                summaryLines: [
                    "到着見込み 16:32",
                    "遅延は現在なし"
                ]
            )
        ),
        actions: []
    )

    static let calendarView = CoreUIViewItem(
        id: "view-calendar",
        kind: .calendar,
        payload: .calendarTimeline(
            CalendarTimelinePayload(
                timezone: "Asia/Tokyo",
                events: [
                    CalendarEventPayload(
                        id: "event-1",
                        title: "定期通院",
                        start: "2026-02-17T16:40:00+09:00",
                        end: "2026-02-17T17:10:00+09:00",
                        location: "赤坂クリニック",
                        travelMin: 17,
                        conflict: false
                    ),
                    CalendarEventPayload(
                        id: "event-2",
                        title: "薬局受け取り",
                        start: "2026-02-17T17:20:00+09:00",
                        end: "2026-02-17T17:40:00+09:00",
                        location: "赤坂薬局",
                        travelMin: 6,
                        conflict: false
                    ),
                ]
            )
        ),
        actions: [
            CoreUIAction(label: "母に送る", type: .tool, name: "share_location")
        ]
    )

    static func document(layout: CoreUILayout) -> CoreUIDocument {
        CoreUIDocument(
            schemaVersion: "1.1",
            message: "16:40の通院に間に合うよう、現在地と予定を表示します。",
            ui: CoreUIDocumentUI(
                layout: layout,
                views: [mapView, calendarView],
                actions: []
            )
        )
    }
}

private struct EmbeddedViewLayoutPreview: View {
    let layout: CoreUILayout

    var body: some View {
        EmbeddedView(
            model: EmbeddedViewModel(document: LayoutPreviewFixtures.document(layout: layout)),
            actionHandler: LayoutPreviewDependencies.actionHandler,
            presentationDriver: LayoutPreviewDependencies.presentationDriver,
            containerID: "preview-\(layout.rawValue)"
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}

#Preview("EmbeddedView Layout v") {
    EmbeddedViewLayoutPreview(layout: .vertical)
}

#Preview("EmbeddedView Layout h") {
    EmbeddedViewLayoutPreview(layout: .horizontal)
}
