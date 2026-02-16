import Foundation

public struct CoordinatePayload: Codable, Sendable {
    public let latitude: Double
    public let longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

public struct MapAnnotationPayload: Codable, Sendable, Identifiable {
    public let id: String
    public let title: String
    public let coordinate: CoordinatePayload

    public init(id: String, title: String, coordinate: CoordinatePayload) {
        self.id = id
        self.title = title
        self.coordinate = coordinate
    }
}

public struct MapRouteSummaryPayload: Codable, Sendable {
    public let originLabel: String
    public let destinationLabel: String
    public let distanceMeters: Double
    public let etaMinutes: Int

    public init(
        originLabel: String,
        destinationLabel: String,
        distanceMeters: Double,
        etaMinutes: Int
    ) {
        self.originLabel = originLabel
        self.destinationLabel = destinationLabel
        self.distanceMeters = distanceMeters
        self.etaMinutes = etaMinutes
    }
}

public struct MapSnapshotPayload: EmbeddedPayload {
    public let center: CoordinatePayload
    public let latitudeDelta: Double
    public let longitudeDelta: Double
    public let annotations: [MapAnnotationPayload]
    public let geofenceRadiusMeters: Double?
    public let routeSummary: MapRouteSummaryPayload?
    public let summaryLines: [String]

    public init(
        center: CoordinatePayload,
        latitudeDelta: Double = 0.02,
        longitudeDelta: Double = 0.02,
        annotations: [MapAnnotationPayload],
        geofenceRadiusMeters: Double? = nil,
        routeSummary: MapRouteSummaryPayload? = nil,
        summaryLines: [String] = []
    ) {
        self.center = center
        self.latitudeDelta = latitudeDelta
        self.longitudeDelta = longitudeDelta
        self.annotations = annotations
        self.geofenceRadiusMeters = geofenceRadiusMeters
        self.routeSummary = routeSummary
        self.summaryLines = summaryLines
    }

    public var hasMap: Bool { true }
    public var listCount: Int { annotations.count + summaryLines.count + (routeSummary == nil ? 0 : 1) }
    public var formFieldCount: Int { 0 }
}
