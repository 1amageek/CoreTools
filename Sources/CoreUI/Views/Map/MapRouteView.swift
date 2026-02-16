import CoreLocation
import MapKit
import SwiftUI

public struct MapRouteView: View {
    public let payload: MapRoutePayload

    public init(payload: MapRoutePayload) {
        self.payload = payload
    }

    private var routeCoordinates: [CLLocationCoordinate2D] {
        payload.path.map {
            CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
        }
    }

    private var region: MKCoordinateRegion {
        let annotationCoordinates = allAnnotations.map {
            CLLocationCoordinate2D(
                latitude: $0.coordinate.latitude,
                longitude: $0.coordinate.longitude
            )
        }
        let allCoordinates = routeCoordinates + annotationCoordinates

        guard let first = allCoordinates.first else {
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 35.681236, longitude: 139.767125),
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            )
        }

        let bounds = allCoordinates.dropFirst().reduce(
            (
                minLat: first.latitude,
                maxLat: first.latitude,
                minLng: first.longitude,
                maxLng: first.longitude
            )
        ) { current, coordinate in
            (
                minLat: min(current.minLat, coordinate.latitude),
                maxLat: max(current.maxLat, coordinate.latitude),
                minLng: min(current.minLng, coordinate.longitude),
                maxLng: max(current.maxLng, coordinate.longitude)
            )
        }

        let latitudeSpan = max((bounds.maxLat - bounds.minLat) * 1.6, 0.01)
        let longitudeSpan = max((bounds.maxLng - bounds.minLng) * 1.6, 0.01)

        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: (bounds.minLat + bounds.maxLat) / 2,
                longitude: (bounds.minLng + bounds.maxLng) / 2
            ),
            span: MKCoordinateSpan(
                latitudeDelta: latitudeSpan,
                longitudeDelta: longitudeSpan
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

    private var allAnnotations: [MapAnnotationPayload] {
        var values: [MapAnnotationPayload] = []

        if let origin = payload.origin {
            values.append(origin)
        }
        if let destination = payload.destination {
            values.append(destination)
        }
        values.append(contentsOf: payload.waypoints)
        return values
    }

    public var body: some View {
        WatchCard {
            VStack(alignment: .leading, spacing: LayoutTokens.compact) {
                header

                Map(initialPosition: .region(region)) {
                    if routeCoordinates.count > 1 {
                        MapPolyline(coordinates: routeCoordinates)
                            .stroke(WatchPalette.accent, lineWidth: 4)
                    }

                    ForEach(allAnnotations, id: \.id) { annotation in
                        Marker(
                            annotation.title,
                            coordinate: CLLocationCoordinate2D(
                                latitude: annotation.coordinate.latitude,
                                longitude: annotation.coordinate.longitude
                            )
                        )
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

                        if let transport = payload.transport {
                            WatchChip(text: transport.uppercased())
                        }
                    }
                }

                if !payload.steps.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(Array(payload.steps.prefix(3).enumerated()), id: \.offset) { _, step in
                            Text(step.text)
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundStyle(WatchPalette.secondaryText)
                                .lineLimit(2)
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
            WatchSectionTitle(text: "Route")
            Spacer()
            Text(etaText)
                .font(.system(size: 24, weight: .heavy, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(WatchPalette.accent)
        }
    }
}

#Preview("MapRouteView/Watch") {
    ZStack {
        Color.black.ignoresSafeArea()

        MapRouteView(
            payload: MapRoutePayload(
                path: [
                    CoordinatePayload(latitude: 35.681236, longitude: 139.767125),
                    CoordinatePayload(latitude: 35.6842, longitude: 139.7614),
                    CoordinatePayload(latitude: 35.6889, longitude: 139.7512)
                ],
                origin: MapAnnotationPayload(
                    id: "origin",
                    title: "現在地",
                    coordinate: CoordinatePayload(latitude: 35.681236, longitude: 139.767125)
                ),
                destination: MapAnnotationPayload(
                    id: "destination",
                    title: "赤坂クリニック",
                    coordinate: CoordinatePayload(latitude: 35.6889, longitude: 139.7512)
                ),
                routeSummary: MapRouteSummaryPayload(
                    originLabel: "東京駅",
                    destinationLabel: "赤坂クリニック",
                    distanceMeters: 5200,
                    etaMinutes: 17
                ),
                transport: "walk",
                steps: [
                    .init(stepID: "s1", text: "丸の内中央口を出て右へ進む"),
                    .init(stepID: "s2", text: "外堀通りを南へ 600m 直進"),
                    .init(stepID: "s3", text: "赤坂見附交差点を左折")
                ],
                summaryLines: ["16:32 到着見込み", "遅延は現在なし"]
            )
        )
        .padding(LayoutTokens.compact)
        .frame(maxWidth: .infinity, minHeight: 320)
    }
}
