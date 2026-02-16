import MapKit
import SwiftUI

public struct MapSnapshotView: View {
    public let payload: MapSnapshotPayload

    public init(payload: MapSnapshotPayload) {
        self.payload = payload
    }

    private var region: MKCoordinateRegion {
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: payload.center.latitude,
                longitude: payload.center.longitude
            ),
            span: MKCoordinateSpan(
                latitudeDelta: payload.latitudeDelta,
                longitudeDelta: payload.longitudeDelta
            )
        )
    }

    private var etaText: String {
        guard let routeSummary = payload.routeSummary else {
            return "--"
        }
        return "\(routeSummary.etaMinutes)m"
    }

    private var distanceText: String {
        guard let routeSummary = payload.routeSummary else {
            return "距離不明"
        }

        if routeSummary.distanceMeters >= 1000 {
            return String(format: "%.1fkm", routeSummary.distanceMeters / 1000)
        }
        return "\(Int(routeSummary.distanceMeters))m"
    }

    public var body: some View {
        WatchCard {
            VStack(alignment: .leading, spacing: LayoutTokens.compact) {
                header

                Map(initialPosition: .region(region)) {
                    ForEach(payload.annotations) { annotation in
                        Marker(
                            annotation.title,
                            coordinate: CLLocationCoordinate2D(
                                latitude: annotation.coordinate.latitude,
                                longitude: annotation.coordinate.longitude
                            )
                        )
                    }

                    if let geofenceRadiusMeters = payload.geofenceRadiusMeters {
                        MapCircle(
                            center: CLLocationCoordinate2D(
                                latitude: payload.center.latitude,
                                longitude: payload.center.longitude
                            ),
                            radius: geofenceRadiusMeters
                        )
                        .foregroundStyle(.orange.opacity(0.16))

                        MapCircle(
                            center: CLLocationCoordinate2D(
                                latitude: payload.center.latitude,
                                longitude: payload.center.longitude
                            ),
                            radius: geofenceRadiusMeters
                        )
                        .stroke(.orange, lineWidth: 1.5)
                    }
                }
                .frame(maxWidth: .infinity)
                .aspectRatio(1.2, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: LayoutTokens.cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: LayoutTokens.cornerRadius)
                        .stroke(WatchPalette.outline, lineWidth: 1)
                )

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: LayoutTokens.tiny) {
                        WatchChip(text: "ETA \(etaText)", tint: WatchPalette.accent.opacity(0.22))
                        WatchChip(text: distanceText)

                        ForEach(payload.annotations) { annotation in
                            WatchChip(text: annotation.title)
                        }
                    }
                }

                if !payload.summaryLines.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(payload.summaryLines, id: \.self) { line in
                            Text(line)
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundStyle(WatchPalette.secondaryText)
                                .lineLimit(2)
                        }
                    }
                }
            }
            .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            WatchSectionTitle(text: "Map")
            Spacer()
            Text(etaText)
                .font(.system(size: 24, weight: .heavy, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(WatchPalette.accent)
        }
    }
}

#Preview("MapSnapshotView/Watch") {
    ZStack {
        Color.black.ignoresSafeArea()

        MapSnapshotView(
            payload: MapSnapshotPayload(
                center: CoordinatePayload(latitude: 35.681236, longitude: 139.767125),
                annotations: [
                    MapAnnotationPayload(
                        id: "current",
                        title: "現在地",
                        coordinate: CoordinatePayload(latitude: 35.681236, longitude: 139.767125)
                    ),
                    MapAnnotationPayload(
                        id: "destination",
                        title: "待ち合わせ",
                        coordinate: CoordinatePayload(latitude: 35.6895, longitude: 139.6917)
                    ),
                ],
                geofenceRadiusMeters: 150,
                routeSummary: MapRouteSummaryPayload(
                    originLabel: "東京駅",
                    destinationLabel: "新宿駅",
                    distanceMeters: 7800,
                    etaMinutes: 18
                ),
                summaryLines: [
                    "母に現在地を共有予定",
                    "到着見込み: 19:10",
                    "位置精度: 高"
                ]
            )
        )
        .padding(LayoutTokens.compact)
        .frame(maxWidth: .infinity, minHeight: 320)
    }
}
